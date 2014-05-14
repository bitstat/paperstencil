class CreateDocumentInstances < ActiveRecord::Migration
  def change
    create_table :document_instances do |t|
      t.references :document
      t.references :submitted_by
      t.timestamps
    end
  end
end
