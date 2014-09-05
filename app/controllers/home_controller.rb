class HomeController < ApplicationController
  def index
    id = Session.maximum(:id)
    redirect_to "/session/#{id}"
  end
end
