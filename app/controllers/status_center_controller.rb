class StatusCenterController < ApplicationController
  def show
    @currentProject = Project.find(params[:id])
    @projects = Project.all()
    @tags=Tag.all().collect{|t| t.name}.uniq
  end

  def all
    data = Hash.new
    begin
      # if params[:project_id]
      # else
      #   project_id = Project.first().id
      # end
      project_id = params[:project_id] ? Project.find(params[:project_id]).id: Project.first().id

      data[:sessions] = Session.select(:id,:pass_rate,:browser, :start_time).where(project_id: project_id).order('start_time ASC')
      data[:tagMap] = {}
      data[:sessions].each{|s|
        s.start_time = Time.parse(s.start_time).strftime('%Y-%m-%d %H:%M:%S')
        data[:tagMap][s.id] = s.tags.collect{|t| t.name}
        #get pass rate if it is not calcualted yet
        if s.pass_rate == nil
          if s.executions.size > 0
            s.executions.group_by{|e| e.result }.each{|k,v|
              if k =~/passed/i
                s.pass_rate = ((v.count.to_f/s.executions.size)*100).round(2)
                #s.update_attribute(:pass_rate,((v.count.to_f/s.executions.size)*100).round(2))
                break
                #this is the case where no pass in the current session
              else
                s.pass_rate = 0
              end
            }
          end
        else
          s.pass_rate = s.pass_rate.to_i
        end
      }

      render json: data
    rescue Exception => e
      data[:error] = e.message.strip
      data[:trace] = e.backtrace.join("<br>")
      render json: data
    end
  end
end
