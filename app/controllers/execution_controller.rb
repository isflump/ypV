class ExecutionController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def storeSession
    @ses = Session.new(JSON.parse(params['session']))
    if @ses.save
      render :text => @ses.id, :status => 200
    else
      render :text => "ERROR", :status => 400
    end
  end


  def storeExecution
    puts JSON.parse(params['execution'])
    puts JSON.parse(params['execution'])['case']
    @exc = Execution.new(JSON.parse(params['execution']))
    if @exc.save
      render :text => "Success", :status => 200
    else
      render :text => "ERROR", :status => 400
    end
  end
end
