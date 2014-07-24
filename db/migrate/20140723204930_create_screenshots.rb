class CreateScreenshots < ActiveRecord::Migration
  def change
    create_table :screenshots do |t|
      t.string :avatar
      t.belongs_to :execution
      t.timestamps
    end
  end
end
