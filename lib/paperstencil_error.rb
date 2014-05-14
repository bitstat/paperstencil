class PaperstencilError < StandardError
  attr_reader :status, :message

  def initialize(status, message=nil)
    @status, @message = status, message
    super(@message)
  end

  HTTP_BAD_REQUEST           = 400
  HTTP_FORBIDDEN             = 403
  HTTP_NOT_FOUND             = 404
  HTTP_INTERNAL_SERVER_ERROR = 500
  HTTP_BAD_GATEWAY           = 502

  ACCESS_DENIED = new(HTTP_FORBIDDEN, "Access Denied")
  URL_INVALID = new(HTTP_BAD_REQUEST, "URL invalid. May be resource removed?")
  DOCUMENT_NOT_FOUND = new(HTTP_BAD_REQUEST, "Document not found")
  UNKNOWN_FORM_TYPE = new(HTTP_BAD_REQUEST, "Unknown form type")
end
