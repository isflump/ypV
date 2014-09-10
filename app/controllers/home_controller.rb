class HomeController < ApplicationController
  def index
    id = Session.maximum(:id)
    puts id
    redirect_to "/session/#{id}" if id
  end
end
