class CreateAuthProviders < ActiveRecord::Migration
  def self.up
    create_table :auth_providers do |t|
      t.string :provider
      t.string :uid
      t.references :user
    end
  end

  def self.down
    drop_table :auth_providers
  end
end
