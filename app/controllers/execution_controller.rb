require 'soap/rpc/driver'
require 'soap/wsdlDriver'

class ExecutionController < ApplicationController

  def show
    @execution = Execution.find_by(id: params[:id])
    @sshots = @execution.screenshots
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
      puts map[Date.today.year.to_s].each{|k,arr|
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
      if @execution.spira_case_id && !@execution.spira_case_id.empty?
        projectId=@execution.session.project.spira_id
        # #set up driver
        driver = SOAP::WSDLDriverFactory.new("http://spirateam.ypg.com/Services/v4_0/ImportExport.svc?wsdl").create_rpc_driver
        # #set up connection
        response =  driver.Connection_Authenticate({userName: YpV::Application::SPIRA_USER_NAME, password: YpV::Application::SPIRA_PASSWORD})
        driver.Connection_ConnectToProject({projectId: projectId}).connection_ConnectToProjectResult
        #
        data[:foundCase]=true
        # #get the description
        desc = driver.TestCase_RetrieveById({testCaseId: @execution.spira_case_id}).testCase_RetrieveByIdResult.description
        data['tcDescription'] = desc ?  desc.strip : "No Description found"

        # #get the steps
        data['tcSteps'] = []
        stepsInfo = driver.TestCase_RetrieveById({testCaseId: @execution.spira_case_id}).testCase_RetrieveByIdResult.testSteps.remoteTestStep
        if stepsInfo
          tempStep = {}
          if stepsInfo.kind_of?(Array)
      		  stepsInfo.each_with_index{ |step ,index|
        			tempStep['tsExpectedResult'] = step.expectedResult.gsub('"','\'').gsub('<div>',"\n").gsub(/\<[^>]*>/,'').strip
        			tempStep['tsDescription'] = step.description.gsub('"','\'').gsub('<div>',"\n").gsub(/<[^>]*>/,'').strip
        			steps.push tempStep
      		  }
      	   else
        		tempStep['tsExpectedResult'] = stepsInfo.expectedResult.gsub('"','\'').gsub('<div>',"\n").gsub(/\<[^>]*>/,'').strip
        		tempStep['tsDescription'] = stepsInfo.description.gsub('"','\'').gsub('<div>',"\n").gsub(/<[^>]*>/,'').strip
        		steps.push tempStep
      	   end
          # stepsInfo.each_with_index{|step ,index|
          #   tempStep = {}
          #   tempStep['tsExpectedResult'] = step.expectedResult.gsub('"','\'').gsub('<div>',"\n").gsub(/\<[^>]*>/,'').strip
          #   tempStep['tsDescription'] = step.description.gsub('"','\'').gsub('<div>',"\n").gsub(/<[^>]*>/,'').strip
          #   tempStep['tsSample'] = step.sampleData ?  step.sampleData : "N/A"
          #   data['tcSteps'].push tempStep
          # }
        end
      else
        data[:foundCase]=false
      end

      render json: data
		rescue Exception => e
			data[:error] = e.message.strip
			data[:trace] = e.backtrace.join("<br>")
			render json: data
		end
  end

end
