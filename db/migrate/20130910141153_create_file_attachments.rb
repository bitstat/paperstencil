class CreateFileAttachments < ActiveRecord::Migration
  def change
    create_table :file_attachments do |t|
      t.string :file_path
      t.string :mime_type
      t.string :filename
      t.references :document
      t.timestamps
    end
  end
end
