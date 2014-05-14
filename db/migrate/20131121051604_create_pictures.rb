class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.column :ref_id, :string
      t.column :value, :text
      t.references :document
      t.timestamps
    end
  end
end
