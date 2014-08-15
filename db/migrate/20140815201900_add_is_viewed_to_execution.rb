class AddIsViewedToExecution < ActiveRecord::Migration
  def change
    add_column :executions, :isViewed, :boolean
  end
end
