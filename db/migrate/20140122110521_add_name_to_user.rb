class AddNameToUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :first_name
      t.string :last_name
    end
  end

  def self.down
    remove_column :users, :first_name, :last_name
  end
end
