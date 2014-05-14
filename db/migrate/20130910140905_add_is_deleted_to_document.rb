class AddIsDeletedToDocument < ActiveRecord::Migration
  def self.up
    add_column :documents, :is_deleted, :boolean, :default => false
  end

  def self.down
    remove_column :documents, :is_deleted
  end
end
