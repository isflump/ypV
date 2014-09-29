require 'soap/rpc/driver'
require 'soap/wsdlDriver'

class ExecutionController < ApplicationController

  def show
    @execution = Execution.find_by(id: params[:id])
    @sshots = @execution.screenshots
    executions = Execution.select(:created_at,:id,:result,:session_id).where(case_name: @execution.case_name).order('executions.created_at ASC')
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
              calendarMap[executions[end_subindex].created_at.strftime("%Y-%m-%d")] << executions[end_subindex]
            else
              calendarMap[executions[end_subindex].created_at.strftime("%Y-%m-%d")] = [executions[end_subindex]]
            end
          end
        end
        break
      end
    }
    @executionHistory = {}
    calendarMap.each{|key, value|
      if @executionHistory.has_key?(Time.parse(key).month)
        @executionHistory[Time.parse(key).month][Time.parse(key).day] = value
      else
        @executionHistory[Time.parse(key).month] = {Time.parse(key).day => value}
      end
    }

    #save this as viewd
    if !@execution.isViewed
      @execution.isViewed = true
      @execution.save
    end
  end


  def getHistoryTrend
    data = Hash.new
    @execution = Execution.find_by(id: params[:id])
    begin

      #overall test case run
      map={}
      obj_arr=Execution.select("executions.id,case_name,result,executions.created_at").joins('JOIN sessions on executions.session_id=sessions.id').where(case_name: @execution.case_name).order( 'executions.created_at ASC' )

      #just a test area to rewrite the graph rendering alogrithm
      data[:exePassNumber] = []
      data[:exeFailNumber] = []
      data[:weekLabel] = []
      data[:weekData] = {}
      start_index=1000
      obj_arr.each{|o|
        week = Date.new(o.created_at.year,o.created_at.month,o.created_at.day).cweek
        if map[o.created_at.year.to_s]
          if map[o.created_at.year.to_s][week.to_s]
            map[o.created_at.year.to_s][week.to_s] << o
          else
            map[o.created_at.year.to_s][week.to_s]=[o]
          end
        else
          map[o.created_at.year.to_s]={week.to_s => [o]}
        end
      }

      if map.size == 1 && map.keys[0] == '2014'
        data[:weekLabel] = (1..Date.today.cweek).to_a.collect{|w| "Week_#{Date.commercial(map.keys[0].to_i,w,1).strftime("%Y-%m-%d")}" }
        data[:exeFailNumber] = [0]*Date.today.cweek
        data[:exePassNumber] = [0]*Date.today.cweek
        data[:execPassRatio] = [0]*Date.today.cweek

        map[map.keys[0]].each{|k,arr|
           start_index = k.to_i-1 if k.to_i < start_index
           pass = arr.collect{|o| o.result =~ /passed/i ? 1 : 0}.sum
           data[:execPassRatio][k.to_i-1] = ((pass.to_f/Float(arr.size))*100).round(1)
           data[:exeFailNumber][k.to_i-1] = arr.size - pass
           data[:exePassNumber][k.to_i-1] = pass
           data[:weekData]["Week_#{Date.commercial(map.keys[0].to_i,k.to_i,1).strftime("%Y-%m-%d")}"]=arr
        }
        data[:weekLabel] = data[:weekLabel][start_index..data[:weekLabel].size-1]
        data[:exeFailNumber] = data[:exeFailNumber][start_index..data[:exeFailNumber].size-1]
        data[:exePassNumber] = data[:exePassNumber][start_index..data[:exePassNumber].size-1]
        data[:execPassRatio] = data[:execPassRatio][start_index..data[:execPassRatio].size-1]

        data[:execPassRatio].each_with_index{|e,i|
          if e == 0 && data[:exeFailNumber][i] == 0
            data[:weekLabel][i]=nil
            data[:exeFailNumber][i]=nil
            data[:exePassNumber][i]=nil
            data[:execPassRatio][i]=nil
          end
        }
        data[:weekLabel].delete_if{|e| e==nil}
        data[:execPassRatio].delete_if{|e| e==nil}
        data[:exeFailNumber].delete_if{|e| e==nil}
        data[:exePassNumber].delete_if{|e| e==nil}

        puts data[:weekLabel].inspect
        puts data[:execPassRatio].inspect
        puts data[:exeFailNumber].inspect
        puts data[:exePassNumber].inspect
        puts data[:weekData]
      end

      # map={}
      # obj_arr.each{|o|
      #   if map[o.created_at.year.to_s]
      #     if map[o.created_at.year.to_s][o.created_at.month.to_s]
      #       map[o.created_at.year.to_s][o.created_at.month.to_s] << o
      #     else
      #       map[o.created_at.year.to_s][o.created_at.month.to_s]=[o]
      #     end
      #   else
      #     map[o.created_at.year.to_s]={o.created_at.month.to_s => [o]}
      #   end
      # }
      #
      # # it is the same year
      # if map.size == 1
      #   data[:label] = (1..Date.today.month).to_a.collect{|m| map.keys[0]+"-"+m.to_s}
      #   value_arr = [0]*Date.today.month
      #   value_pass_var = [0]*Date.today.month
      #   map[map.keys[0]].each{|k,arr|
      #     value_arr[k.to_i-1]= arr.size
      #     value_pass_var[k.to_i-1] = arr.collect{|o| o.result =~ /passed/i ? 1 : 0}.sum
      #   }
      # #TODO: consider the case when the year changed
      # end
      # #delete leading 0
      # start_index=0
      # value_arr.each_with_index{|v,i|
      #   if v == 0 && value_arr[i+1] != 0
      #     start_index = i
      #     break
      #   end
      # }
      #
      # data[:label]=data[:label][start_index...data[:label].size]
      # value_arr = value_arr[start_index...value_arr.size]
      # value_pass_var = value_pass_var[start_index...value_pass_var.size]
      # value_arr.each_with_index{|a, i| data[:executionNumber] << value_arr[0..i].sum }
      # value_pass_var.each_with_index{|a, i| data[:executionPassNumber] << value_pass_var[0..i].sum }
      #
      #
      # #generate bar chart data
      # data[:lastExecutionLabel] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
      # data[:lastExecutionLabel] = data[:lastExecutionLabel][0...Date.today.month]
      # data[:lastExecutionPass] = [0]*Date.today.month
      # data[:lastExecutionFail] = [0]*Date.today.month
      # map[Date.today.year.to_s].each{|k,arr|
      #   data[:lastExecutionFail][k.to_i-1]= arr.collect{|o| o.result =~ /failed/i ? 1 : 0}.sum
      #   data[:lastExecutionPass][k.to_i-1] = arr.collect{|o| o.result =~ /passed/i ? 1 : 0}.sum
      # }
      #
      # #when it is 0, it means no cases execution found on these month
      # #delete leading 0 in the data array
      # pass_start_index=0
      # data[:lastExecutionPass].each_with_index{|v,i|
      #   if v == 0 && data[:lastExecutionPass][i+1] != 0
      #     pass_start_index = i+1
      #     break
      #   end
      # }
      #
      # fail_start_index=0
      # data[:lastExecutionFail].each_with_index{|v,i|
      #   if v == 0 && data[:lastExecutionFail][i+1] != 0
      #     fail_start_index = i+1
      #     break
      #   end
      # }
      #
      # start_index = pass_start_index > fail_start_index ? fail_start_index : pass_start_index
      # data[:lastExecutionLabel] = data[:lastExecutionLabel][start_index...data[:lastExecutionLabel].size]
      # data[:lastExecutionPass] = data[:lastExecutionPass][start_index...data[:lastExecutionPass].size]
      # data[:lastExecutionFail] = data[:lastExecutionFail][start_index...data[:lastExecutionFail].size]

      render json: data
    rescue Exception => e
      data[:error] = e.message.strip
      data[:trace] = e.backtrace.join("<br>")
      render json: data
    end
  end


  #
  # Post request to retreieve the data from SPIRA Soap API based on either the name or the ID of the case
  #
  def getSpira
		data = Hash.new
		begin
      @execution = Execution.find_by(id: params[:id])
      projectName=@execution.session.project.name
      projectId=@execution.session.project.spira_id
      # #set up driver
      driver = SOAP::WSDLDriverFactory.new("http://spirateam.ypg.com/Services/v4_0/ImportExport.svc?wsdl").create_rpc_driver
      # #set up connection
      response =  driver.Connection_Authenticate({userName: YpV::Application::SPIRA_USER_NAME, password: YpV::Application::SPIRA_PASSWORD})
      driver.Connection_ConnectToProject({projectId: projectId}).connection_ConnectToProjectResult
      testCaseId=nil
      if !@execution.spira_case_id || @execution.spira_case_id.empty?
        if YpV::Application::SPIRA_TC_NAME_MAP[projectName].has_key?(@execution.case_id)
          testCaseId = YpV::Application::SPIRA_TC_NAME_MAP[projectName][@execution.case_id].testCaseId
        end
      else
        testCaseId = @execution.spira_case_id
      end

      if testCaseId
        data[:foundCase]=true
        # #get the description
        tcObj = driver.TestCase_RetrieveById({testCaseId: testCaseId}).testCase_RetrieveByIdResult
        data['tcName'] = tcObj.name.strip
        data['tcLink'] = "http://spirateam.ypg.com/"+projectId.to_s+"/TestCase/"+testCaseId.to_s+".aspx"
        data['tcDescription'] = tcObj.description ?  tcObj.description.strip : "No Description found"
        # #get the steps

        steps = []
        stepsInfo = tcObj.testSteps.remoteTestStep
        if stepsInfo
           if stepsInfo.kind_of?(Array)
      		  stepsInfo.each_with_index{ |step ,index|
        			steps << {:tsExpectedResult => "#{step.expectedResult.gsub('#333333','#aaa').gsub('rgb(51, 51, 51)','#aaa')}" ,
                        :tsDescription => "#{step.description.gsub('#333333','#aaa').gsub('rgb(51, 51, 51)','#aaa')}" }
      		  }
      	   else
            tempStep = {}
            if stepsInfo.expectedResult
      		    tempStep['tsExpectedResult'] = stepsInfo.expectedResult.gsub('#333333','#aaa').gsub('rgb(51, 51, 51)','#aaa')
            else
              tempStep['tsExpectedResult'] = "undefined"
            end
            if stepsInfo.description
              puts stepsInfo
      		    tempStep['tsDescription'] = stepsInfo.description.gsub('#333333','#aaa').gsub('rgb(51, 51, 51)','#aaa')
            else
              tempStep['tsDescription'] = "undefined"
            end
        		steps.push tempStep
      	   end
           data['tcSteps'] = steps
           puts data
        else
          data[:foundCase]=false
        end
      end

      render json: data
		rescue Exception => e
      data[:foundCase]=false
			data[:error] = e.message.strip
			data[:trace] = e.backtrace.join("<br>")
			render json: data
		end
  end

  def getImgName
     render text: Execution.select(:case_name).where(id: params[:id])[0].case_name
  end

  #
  # Post request to get the current execution and selected execution detail as compare execution
  # and return to JS for comparsion rendering
  #
  def getCompareExecution
    data = Hash.new
    begin
      data[:current_execution]=Execution.find_by(id: params[:id])
      data[:compare_execution]=Execution.find_by(id: params[:compare_id])
      render json: data
    rescue Exception => e
      data[:error] = e.message.strip
      data[:trace] = e.backtrace.join("<br>")
      render json: data
    end
  end

end
