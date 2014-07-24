class CreateExecutions < ActiveRecord::Migration
  def change
    create_table :executions do |t|
      t.string :case_name
      t.string :case_id
      t.string :markers
      t.string :scenario
      t.integer :line
      t.string :location
      t.string :result
      t.string :keyword
      t.decimal :duration
      t.text :exception
      t.text :log
      t.string :ss_path
      t.belongs_to :session
      t.timestamps
    end
  end
end
