class DocumentInstanceController < ApplicationController
  before_filter :authenticate_user!

  def list
    @document = current_user.documents.find(params[:document_id])
    @document_instances = @document.document_instances
    render :layout => "application"
  end
end
