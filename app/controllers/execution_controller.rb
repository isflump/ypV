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
      #We measure the interval weekly
      day_factor=1
      #construct history graph
      current_begining_of_week=Date.today.at_beginning_of_week
      time_range = (-7..-1).collect{ |i| { :start => (current_begining_of_week - day_factor * i*-1).to_s , :end => (current_begining_of_week - day_factor * (i*-1-1)).to_s } }
      puts time_range
      #range label
      data[:label] = time_range.collect{|c| c[:start]}

      obj_arr=time_range.collect{|c|
        Execution.select("case_name,result,executions.created_at").joins('JOIN sessions on executions.session_id=sessions.id').where(case_name: @execution.case_name , created_at:c[:start] .. c[:end])
      }
      value_arr = obj_arr.collect{|o| o.size }
      data[:executionNumber]= []
      value_arr.each_with_index{|a, i| data[:executionNumber] << value_arr[0..i].sum }

      data[:executionPassNumber]= []
      value_pass_var = obj_arr.collect{|o| o.size == 0 ? 0 : o.collect{|so| 1 if so.result =~ /passed/i}.sum }
      value_pass_var.each_with_index{|a, i| data[:executionPassNumber] << value_pass_var[0..i].sum }

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
          stepsInfo.each_with_index{|step ,index|
            tempStep = {}
            tempStep['tsExpectedResult'] = step.expectedResult.gsub('"','\'').gsub('<div>',"\n").gsub(/\<[^>]*>/,'').strip
            tempStep['tsDescription'] = step.description.gsub('"','\'').gsub('<div>',"\n").gsub(/<[^>]*>/,'').strip
            tempStep['tsSample'] = step.sampleData ?  step.sampleData : "N/A"
            data['tcSteps'].push tempStep
          }
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
