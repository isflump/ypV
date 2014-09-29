class SessionController < ApplicationController

  def show
    @session = Session.find_by(id: params[:id])
    if @session
      sessions = Session.select(:start_time,:id, :browser).where(project_id: @session.project_id).order('sessions.created_at ASC')


      #this is the code to generate the side calendar candidate
      #we will only display 7 days of executions from today.
      calendarMap={}
      sessions.each_with_index{ |s,i|
        if s.id == params[:id].to_i
          calendarMap[s.start_time.gsub(/_.*/,"")] = [s]

          start_subindex=end_subindex=i
          while calendarMap.keys.size < 7
            break if (start_subindex < 0 && end_subindex >= sessions.size)
            if start_subindex == 0
              start_subindex -= 1
            elsif start_subindex > 0
              start_subindex -= 1
              if calendarMap.has_key?(sessions[start_subindex].start_time.gsub(/_.*/,""))
                calendarMap[sessions[start_subindex].start_time.gsub(/_.*/,"")] << sessions[start_subindex]
              else
                calendarMap[sessions[start_subindex].start_time.gsub(/_.*/,"")] = [sessions[start_subindex]]
              end
            end

            if end_subindex == (sessions.size-1)
              end_subindex += 1
            elsif end_subindex < (sessions.size-1)
              end_subindex += 1
              if calendarMap.has_key?(sessions[end_subindex].start_time.gsub(/_.*/,""))
                calendarMap[sessions[end_subindex].start_time.gsub(/_.*/,"")] << sessions[end_subindex]
              else
                calendarMap[sessions[end_subindex].start_time.gsub(/_.*/,"")] = [sessions[end_subindex]]
              end
            end
          end
          break
        end
      }

      @sessionHistory = {}
      calendarMap.each{|key, value|
        if @sessionHistory.has_key?(Time.parse(key).month)
          @sessionHistory[Time.parse(key).month][Time.parse(key).day] = value
        else
          @sessionHistory[Time.parse(key).month] = {Time.parse(key).day => value}
        end
      }
    end
  end


  def getStatus
    data = Hash.new
    begin
      ses = Session.find_by(id: params[:id])
      data[:executions] = ses.executions.select(:case_id,:case_name,:scenario,:duration,:spira_case_id,:location,:result,:id,:created_at,:isViewed)
      #find the lastest five executions
      data[:shortHistoryMap]={}
      for exec in data[:executions]
        data[:shortHistoryMap][exec.id] = Execution.select(:result,:id,:created_at).where(case_id: exec.case_id).where("created_at < ?", exec.created_at).order('executions.created_at DESC').limit(4).reverse
      end
      data[:sessionStatusPass]=0
      data[:sessionStatusFail]=0
      data[:executions].group_by{|e| e.result }.each{|k,v|
        if k =~/passed/i
          data[:sessionStatusPass] = v.count
        else
          data[:sessionStatusFail] = v.count
        end
      }
      #calculate the pass rate
      if data[:executions].size > 0
        if data[:sessionStatusPass] == 0
          ses.update_attribute(:pass_rate, 0)
        else
          ses.update_attribute(:pass_rate, ((data[:sessionStatusPass].to_f/data[:executions].size)*100).round(2))
        end
      end
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

  def getAllSessions
    data = Hash.new
    begin
      data[:sessions] = Session.all().order('sessions.created_at ASC').collect{|s|
        s.start_time=Time.parse(s.start_time).strftime('%Y-%m-%dT%H:%M:%S') if s.start_time
        s.end_time=Time.parse(s.end_time).strftime('%Y-%m-%dT%H:%M:%S') if s.end_time
        s
      }
      render json: data
    rescue Exception => e
      data[:error] = e.message.strip
      data[:trace] = e.backtrace.join("<br>")
      render json: data
    end
  end

  def getSessionInfoById
    data = Hash.new()
    id = params[:sid]
    begin
      session =  Session.find(id)
      data[:start_at] = session.start_time.split('_')[1].insert(2,':').insert(5,':')
      data[:end_at] = session.end_time.split('_')[1].insert(2,':').insert(5,':')
      data[:device] = session.browser
      data[:os] = session.os
      data[:ip] = session.ip
      data[:base_url] = session.base_url
      data[:result_pass] = session.executions.collect{|e| e.result=~/pass/i ? 1 : 0}.sum
      data[:result_all] = session.executions.size

      render json: data
    rescue Exception => e
      data[:error] = e.message.strip
      data[:trace] = e.backtrace.join("<br>")
      render json: data
    end
  end

  def getSpiraStructure
    data = Hash.new()
    data[:spira_cases] = []
    session =  Session.find(params[:id])
    projectName=session.project.name
    begin
      if YpV::Application::SPIRA_TC_NAME_MAP[projectName]
          YpV::Application::SPIRA_TC_NAME_MAP[projectName].keys.each_with_index do |key, index|
            data[:spira_cases] << {
              :name => key,
              :order => index,
              :id=> YpV::Application::SPIRA_TC_NAME_MAP[projectName][key].testCaseId,
              :isFolder => YpV::Application::SPIRA_TC_NAME_MAP[projectName][key].folder,
              :indentLevel => YpV::Application::SPIRA_TC_NAME_MAP[projectName][key].indentLevel,
              :author => YpV::Application::SPIRA_TC_NAME_MAP[projectName][key].authorName
            }
          end
      end
      render json: data
    rescue Exception => e
      puts e
      data[:error] = e.message.strip
      data[:trace] = e.backtrace.join("<br>")
      render json: data
    end
  end
end
