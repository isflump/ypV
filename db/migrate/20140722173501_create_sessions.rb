class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.string :start_time
      t.string :end_time
      t.string :tlib_version
      t.string :selenium_version
      t.string :python_version
      t.string :os
      t.string :processor
      t.string :machine
      t.string :ip
      t.string :browser
      t.string :base_url
      t.timestamps
    end
  end
end
