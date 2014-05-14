module ApplicationHelper
  def get_emails(str)
    str.split(",").map(&:strip).reject(&:empty?).select do |email|
      if Devise::email_regexp =~ email
        true
      else
        flash.now[:notice] = "Invalid email address has been removed."
        false
      end
    end
  end

  def get_document_instance_by_id(document_instance_id)
    doc_instnace = DocumentInstance.find(document_instance_id)
    assert_document_instance(doc_instnace)
    doc_instnace
  end

  def get_document_by_address(address)
    document = Document.where(:address => address).first
    assert_document(document)
    document
  end

  def get_document_by_id(id)
    document = Document.find(id)
    assert_document(document)
    document
  end

  def assert_document_instance(doc_instnace)
    raise PaperstencilError::URL_INVALID if doc_instnace.nil?
    assert_document(doc_instnace.document)
  end

  def assert_document(document)
    raise PaperstencilError::DOCUMENT_NOT_FOUND if document.nil?
    raise PaperstencilError::ACCESS_DENIED unless document.can_be_accessed?(current_user)
  end
end
