class CreateFieldInstances < ActiveRecord::Migration
  def change
    create_table :field_instances do |t|
      t.column :design, :text
      t.column :value, :text
      t.references :field
      t.references :document_instance
      t.timestamps
    end
  end
end
