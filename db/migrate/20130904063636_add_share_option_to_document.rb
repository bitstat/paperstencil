class AddShareOptionToDocument < ActiveRecord::Migration
  def self.up
    add_column :documents, :share_option, :string, :default => Document::SHARE_OPTIONS[:none]
  end

  def self.down
    remove_column :documents, :share_option
  end
end
