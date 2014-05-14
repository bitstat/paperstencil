class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.column :type, :string
      t.column :value, :text
      t.references :document
      t.timestamps
    end
  end
end
