class StatusCenterController < ApplicationController
  def index
    @session = Session.find_by(id: params[:id])
  end
end
