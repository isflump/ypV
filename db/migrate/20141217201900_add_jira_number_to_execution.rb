class AddJiraNumberToExecution < ActiveRecord::Migration
  def change
	add_column :executions, :jira_number, :string
  end
end
