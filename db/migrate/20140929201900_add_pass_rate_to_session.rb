class AddPassRateToSession < ActiveRecord::Migration
  def change
    add_column :sessions, :pass_rate, :string
	add_column :sessions, :coverage_rate, :string
  end
end
