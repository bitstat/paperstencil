class FileController < ApplicationController
  before_filter :authenticate_user!

  def serve
    field_instance = FieldInstance.find(params[:field_instance_id])
    doc_instance = field_instance.document_instance
    assert_document_instance(doc_instance)

    value = field_instance.value
    send_file value['file_path'], :filename => value['file_name'], :type => value['type']
  end

  def attachment
    file_attachment = FileAttachment.find(params[:attachment_id])
    document = file_attachment.document
    assert_document(document)
    send_file file_attachment.file_path, :filename => file_attachment.filename, :type => file_attachment.mime_type
  end

end
