class AddPlanToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :plan, :string
  end

  def self.down
    remove_column :users, :plan
  end
end
