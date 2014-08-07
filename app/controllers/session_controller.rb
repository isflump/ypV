class SessionController < ApplicationController

  def show
    @session = Session.find_by(id: params[:id])
    @executions = @session.executions.select(:case_id,:case_name,:scenario,:duration,:spira_case_id,:location,:result,:id)

  end


  def getStatus
    data = Hash.new
    begin
      data[:executions] = Session.find_by(id: params[:id]).executions.select(:case_id,:case_name,:scenario,:duration,:spira_case_id,:location,:result,:id)

      data[:executions].group_by{|e| e.result }.each{|k,v|
        if k =~/passed/i
          data[:sessionStatusPass] = v.count
        else
          data[:sessionStatusFail] = v.count
        end
      }

      #genearte location bar chart data
      data[:sessionLocationLabel]=[]
      data[:sessionLocationPass]=[]
      data[:sessionLocationFail]=[]

      data[:executions].group_by{|e| e.location.match(/([\w_]+)[\\|\/|\\\\].*/)[1].to_s }.collect{|k,v|
        { k => v.group_by{|e| e.result}.map{|k,vv| {k => vv.count} } }
      }.each{ |v|
        data[:sessionLocationLabel] << v.keys[0]
        data[:sessionLocationPass] << v[v.keys[0]].collect{|o| o.has_key?("passed") ? o["passed"] : 0}.sum
        data[:sessionLocationFail] << v[v.keys[0]].collect{|o| o.has_key?("failed") ? o["failed"] : 0}.sum
      }
      render json: data
    rescue Exception => e
      data[:error] = e.message.strip
      data[:trace] = e.backtrace.join("<br>")
      render json: data
    end
  end

end
