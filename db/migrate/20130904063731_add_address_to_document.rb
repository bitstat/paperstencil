class AddAddressToDocument < ActiveRecord::Migration
  def self.up
    add_column :documents, :address, :string
  end

  def self.down
    remove_column :documents, :address
  end
end
