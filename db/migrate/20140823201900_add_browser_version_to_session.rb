class AddBrowserVersionToSession < ActiveRecord::Migration
  def change
    add_column :sessions, :browser_version, :string
  end
end
