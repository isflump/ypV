class HomeController < ApplicationController
  def index
  	@projects = Project.all()
  	if params[:id]
  		@currentProject = Project.where(:id => params[:id]).first
  		ses = Session.where(:project_id=> params[:id]).order('created_at DESC').first
  		id = ses.id if ses
    else
    	id = Session.maximum(:id)
    end
    redirect_to "/session/#{id}" if id
  end
end
