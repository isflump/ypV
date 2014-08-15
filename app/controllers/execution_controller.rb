require 'soap/rpc/driver'
require 'soap/wsdlDriver'

class ExecutionController < ApplicationController

  def show
    @execution = Execution.find_by(id: params[:id])
    @sshots = @execution.screenshots

    executions = Execution.select(:created_at,:id,:result).where(case_name: @execution.case_name).order('executions.created_at ASC')
    calendarMap={}
    executions.each_with_index{ |s,i|
      if s.id == params[:id].to_i
        calendarMap[s.created_at.strftime("%Y-%m-%d")] = [s]

        start_subindex=i
        end_subindex=i
        while calendarMap.keys.size < 7
          break if (start_subindex < 0 && end_subindex >= executions.size)
          if start_subindex == 0
            start_subindex -= 1
          elsif start_subindex > 0
            start_subindex -= 1
            if calendarMap.has_key?(executions[start_subindex].created_at.strftime("%Y-%m-%d"))
              calendarMap[executions[start_subindex].created_at.strftime("%Y-%m-%d")] << executions[start_subindex]
            else
              calendarMap[executions[start_subindex].created_at.strftime("%Y-%m-%d")] = [executions[start_subindex]]
            end
          end

          if end_subindex == (executions.size-1)
            end_subindex += 1
          elsif end_subindex < (executions.size-1)
            end_subindex += 1
            if calendarMap.has_key?(executions[end_subindex].created_at.strftime("%Y-%m-%d"))
              calendarMap[executions[end_subindex].created_at.strftime("%Y-%m-%d")] << executions[start_subindex]
            else
              calendarMap[executions[end_subindex].created_at.strftime("%Y-%m-%d")] = [executions[start_subindex]]
            end
          end
        end
        break
      end
    }
    puts calendarMap
    @executionHistory = {}
    calendarMap.each{|key, value|
      if @executionHistory.has_key?(Time.parse(key).month)
        @executionHistory[Time.parse(key).month][Time.parse(key).day] = value
      else
        @executionHistory[Time.parse(key).month] = {Time.parse(key).day => value}
      end
    }

    #save this as viewd
    @execution.isViewed = true
    @execution.save
  end


  def getHistoryTrend
    data = Hash.new
    @execution = Execution.find_by(id: params[:id])
    begin
      # #We measure the interval weekly
      # day_factor=1
      # #construct history graph
      # current_begining_of_week=Date.today.at_beginning_of_week
      # time_range = (-7..-1).collect{ |i| { :start => (current_begining_of_week - day_factor * i*-1).to_s , :end => (current_begining_of_week - day_factor * (i*-1-1)).to_s } }
      # #puts time_range
      # #range label
      # data[:label] = time_range.collect{|c| c[:start]}
      #
      # obj_arr=time_range.collect{|c|
      #   Execution.select("case_name,result,executions.created_at").joins('JOIN sessions on executions.session_id=sessions.id').where(case_name: @execution.case_name , created_at:c[:start] .. c[:end])
      # }
      # value_arr = obj_arr.collect{|o| o.size }
      # data[:executionNumber]= []
      # value_arr.each_with_index{|a, i| data[:executionNumber] << value_arr[0..i].sum }
      #
      # data[:executionPassNumber]= []
      # value_pass_var = obj_arr.collect{|o| o.size == 0 ? 0 : o.collect{|so| 1 if so.result =~ /passed/i}.sum }
      # value_pass_var.each_with_index{|a, i| data[:executionPassNumber] << value_pass_var[0..i].sum }


      #new alogrithm
      #overall test case run
      data[:executionNumber] = []
      data[:executionPassNumber] = []
      map={}
      obj_arr=Execution.select("case_name,result,executions.created_at").joins('JOIN sessions on executions.session_id=sessions.id').where(case_name: @execution.case_name).order( 'executions.created_at ASC' )
      obj_arr.each{|o|
        if map[o.created_at.year.to_s]
          if map[o.created_at.year.to_s][o.created_at.month.to_s]
            map[o.created_at.year.to_s][o.created_at.month.to_s] << o
          else
            map[o.created_at.year.to_s][o.created_at.month.to_s]=[o]
          end
        else
          map[o.created_at.year.to_s]={o.created_at.month.to_s => [o]}
        end
      }
      # it is the same year
      if map.size == 1
        data[:label] = (1..Date.today.month).to_a.collect{|m| map.keys[0]+"-"+m.to_s}
        value_arr = [0]*Date.today.month
        value_pass_var = [0]*Date.today.month
        map[map.keys[0]].each{|k,arr|
          value_arr[k.to_i-1]= arr.size
          value_pass_var[k.to_i-1] = arr.collect{|o| o.result =~ /passed/i ? 1 : 0}.sum
        }
      end
      #delete leading 0
      start_index=0
      value_arr.each_with_index{|v,i|
        if v == 0 && value_arr[i+1] != 0
          start_index = i
          break
        end
      }

      data[:label]=data[:label][start_index...data[:label].size]
      value_arr = value_arr[start_index...value_arr.size]
      value_pass_var = value_pass_var[start_index...value_pass_var.size]
      value_arr.each_with_index{|a, i| data[:executionNumber] << value_arr[0..i].sum }
      value_pass_var.each_with_index{|a, i| data[:executionPassNumber] << value_pass_var[0..i].sum }


      #generate bar chart
      data[:lastExecutionLabel] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
      data[:lastExecutionLabel] = data[:lastExecutionLabel][0...Date.today.month]
      data[:lastExecutionPass] = [0]*Date.today.month
      data[:lastExecutionFail] = [0]*Date.today.month
      map[Date.today.year.to_s].each{|k,arr|
        data[:lastExecutionFail][k.to_i-1]= arr.collect{|o| o.result =~ /failed/i ? 1 : 0}.sum
        data[:lastExecutionPass][k.to_i-1] = arr.collect{|o| o.result =~ /passed/i ? 1 : 0}.sum
      }

      #delete leading 0
      pass_start_index=0
      data[:lastExecutionPass].each_with_index{|v,i|
        if v == 0 && data[:lastExecutionPass][i+1] != 0
          pass_start_index = i+1
          break
        end
      }

      fail_start_index=0
      data[:lastExecutionFail].each_with_index{|v,i|
        if v == 0 && data[:lastExecutionFail][i+1] != 0
          fail_start_index = i+1
          break
        end
      }

      start_index = pass_start_index > fail_start_index ? fail_start_index : pass_start_index
      data[:lastExecutionLabel] = data[:lastExecutionLabel][start_index...data[:lastExecutionLabel].size]
      data[:lastExecutionPass] = data[:lastExecutionPass][start_index...data[:lastExecutionPass].size]
      data[:lastExecutionFail] = data[:lastExecutionFail][start_index...data[:lastExecutionFail].size]

      render json: data
    rescue Exception => e
      data[:error] = e.message.strip
      data[:trace] = e.backtrace.join("<br>")
      render json: data
    end
  end

  def getSpira
    puts params
		data = Hash.new
		begin
      @execution = Execution.find_by(id: params[:id])

      projectId=@execution.session.project.spira_id
      # #set up driver
      driver = SOAP::WSDLDriverFactory.new("http://spirateam.ypg.com/Services/v4_0/ImportExport.svc?wsdl").create_rpc_driver
      # #set up connection
      response =  driver.Connection_Authenticate({userName: YpV::Application::SPIRA_USER_NAME, password: YpV::Application::SPIRA_PASSWORD})
      driver.Connection_ConnectToProject({projectId: projectId}).connection_ConnectToProjectResult
      testCaseId=nil

      if !@execution.spira_case_id && @execution.spira_case_id.empty?
        testCaseNo = driver.TestCase_Count({}).testCase_CountResult.to_i
        puts testCaseNo
        for i in 1..((testCaseNo / 250).to_i + 1)
    			i == 1 ? startPos =  1 : startPos = (i - 1) * 250
    			driver.TestCase_Retrieve({startingRow: startPos,numberOfRows: 250}).testCase_RetrieveResult.remoteTestCase.each_with_index{|tc,i|
    			if tc.name.strip == @execution.case_id.strip
    				testCaseId = tc.testCaseId
    				break
    			end
    			}
    		end
    		# driver.TestCase_Retrieve({startingRow: 1,numberOfRows: testCaseNo}).testCase_RetrieveResult.remoteTestCase.each_with_index{ |tc,i|
    		#     puts "#{tc.name.strip}    #{@execution.case_id.strip}"
      	# 		if tc.name.strip == @execution.case_id.strip
      	# 			testCaseId = tc.testCaseId
      	# 			break
      	# 		end
    		# }
      else
        testCaseId = @execution.spira_case_id
      end

      if testCaseId
        data[:foundCase]=true
        # #get the description
        tcObj = driver.TestCase_RetrieveById({testCaseId: @execution.spira_case_id}).testCase_RetrieveByIdResult
        data['tcName'] = tcObj.name.strip
        data['tcLink'] = "http://spirateam.ypg.com/"+projectId.to_s+"/TestCase/"+testCaseId.to_s+".aspx"
        data['tcDescription'] = tcObj.description ?  tcObj.description.strip : "No Description found"
        # #get the steps

        steps = []
        stepsInfo = tcObj.testSteps.remoteTestStep
        if stepsInfo
           if stepsInfo.kind_of?(Array)
      		  stepsInfo.each_with_index{ |step ,index|
        			steps << {:tsExpectedResult => "#{step.expectedResult.gsub('"','\'').gsub('<div>',"\n").gsub(/\<[^>]*>/,'').strip}" ,
                        :tsDescription => "#{step.description.gsub('"','\'').gsub('<div>',"\n").gsub(/<[^>]*>/,'').strip}" }
      		  }
      	   else
            tempStep = {}
        		tempStep['tsExpectedResult'] = stepsInfo.expectedResult.gsub('"','\'').gsub('<div>',"\n").gsub(/\<[^>]*>/,'').strip
        		tempStep['tsDescription'] = stepsInfo.description.gsub('"','\'').gsub('<div>',"\n").gsub(/<[^>]*>/,'').strip
        		steps.push tempStep
      	   end
           data['tcSteps'] = steps
        else
          data[:foundCase]=false
        end
      end

      render json: data
		rescue Exception => e
			data[:error] = e.message.strip
			data[:trace] = e.backtrace.join("<br>")
			render json: data
		end
  end

end
