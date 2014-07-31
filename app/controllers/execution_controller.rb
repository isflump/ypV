require 'soap/rpc/driver'
require 'soap/wsdlDriver'

class ExecutionController < ApplicationController

  def show
    puts params
    @execution = Execution.find_by(id: params[:id])
    @sshots = @execution.screenshots
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
        data['tcDescription'] = driver.TestCase_RetrieveById({testCaseId: @execution.spira_case_id}).testCase_RetrieveByIdResult.description
        data['tcDescription'] = data['tcDescription'] ?  data['tcDescription'].strip : ""

        # #get the steps
        data['tcSteps'] = []
        stepsInfo = driver.TestCase_RetrieveById({testCaseId: @execution.spira_case_id}).testCase_RetrieveByIdResult.testSteps.remoteTestStep
        if stepsInfo
          stepsInfo.each_with_index{|step ,index|
            tempStep = {}
            tempStep['tsExpectedResult'] = step.expectedResult.gsub('"','\'').gsub('<div>',"\n").gsub(/\<[^>]*>/,'').strip
            tempStep['tsDescription'] = step.description.gsub('"','\'').gsub('<div>',"\n").gsub(/<[^>]*>/,'').strip
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
