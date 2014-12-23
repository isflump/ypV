class CreateJiras < ActiveRecord::Migration
  def change
    create_table :jiras do |t|
      t.string :case_name
      t.string :jira_id
      t.string :jira_link

      t.timestamps
    end
  end
end
