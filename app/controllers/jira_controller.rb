require 'soap/rpc/driver'
require 'soap/wsdlDriver'

class JiraController < ApplicationController
  #
  # Post request to get the current execution and selected execution detail as compare execution
  # and return to JS for comparsion rendering
  #
  def save_jira
    data = Hash.new
    begin
      jira = Jira.new
      jira.case_name = params[:case_name]
      jira.jira_id = params[:jira]
      begin
        if jira.save
          data['success'] = "Done"
          render json: data
        end
      rescue
        jira = Jira.find_by(case_name: params[:case_name])
        jira.update_attribute(:jira_id, params[:jira])
        render json: data
      end
    rescue Exception => e
      data[:error] = e.message.strip
      data[:trace] = e.backtrace.join("<br>")
      render json: data
    end
  end


  def destroy
    data = Hash.new
    begin
      Jira.find(params[:id]).destroy
      data['success'] = "Done"
      render json: data
    rescue Exception => e
      data[:error] = e.message.strip
      data[:trace] = e.backtrace.join("<br>")
      render json: data
    end
  end

end
