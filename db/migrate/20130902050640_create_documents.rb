class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.column :title, :string, :null => false
      t.column :value, :text
      t.references :user
      t.timestamps
    end
  end
end
