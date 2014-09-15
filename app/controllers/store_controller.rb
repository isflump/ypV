class StoreController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def storeSession
    @project=Project.find_by_name(params[:project])
    if @project
      @ses = Session.new(JSON.parse(params[:session]))
      @ses.project_id = @project.id
      if @ses.save
        if params[:tag]
          params[:tag].split(";").each{|t|
            Tag.create(:name => t , :session_id => @ses.id)
          }
        end

        render :text => @ses.id, :status => 200
      else
        render :text => "ERROR", :status => 400
      end
    else
      render :text => "Cannot find project #{params[:project]}, please contact your ypv administrator", :status => 400
    end
  end


  def storeExecution
    @exc = Execution.new(JSON.parse(params[:execution]))
    if @exc.save
      render :text => @exc.id, :status => 200
    else
      render :text => "ERROR: #{@exc.errors.full_messages.join()}", :status => 400
    end
  end

  def storeScreenShot
    @exec = Execution.find_by(id: params[:execution_id])
    @ss = Screenshot.new(:avatar => params[:file], :execution_id => @exec.id)
    @ss.save
    render :text => "Success", :status => 200
  end
end
