class ExecutionController < ApplicationController

  def show
    puts params
    @execution = Execution.find_by(id: params[:id])
    @sshots = @execution.screenshots
  end
end
