class DocumentController < ApplicationController
  before_filter :authenticate_user!

  def design_create
    @document = Document.new
    @document.title = "Title Unknown #{Time.now.strftime("%Y-%b-%d %H:%M")}"

    @document.user = current_user
    @document.save!
    redirect_to action: 'design_edit', document_id: @document.id, status: :found
  end

  def design_edit
    @document = fetch_document_for_owner
    render :layout => "document_design"
  end

  def design_list
    @documents = current_user.documents
  end

  def design_structure
    document = get_document_by_id(params[:document_id])
    structure = document.value
    render :json => {:status => :ok, :design_struct => (structure.nil? ? [] : structure) }
  end

  def design_pictures
    pictures = fetch_pictures(params[:document_id], nil)
    render :json => {:status => :ok, :pictures => pictures.all.map(&:data_as_json)}
  end

  def design_fields
    fields = fetch_fields(params[:document_id], nil)
    render :json => {:status => :ok, :fields => fields.all.map(&:data_as_json)}
  end

  def title_update
    document = fetch_document_for_owner
    document.title = params[:title]
    document.save!
    render :json => {:status => "ok"}
  end

  def design_save
    @document = fetch_document_for_owner
    if request.post?
      ActiveRecord::Base.transaction do
        if @document.save_design(params[:doc_design])
          render :json => {:status => :ok}
          return
        else
          render :json => {:status => :failure, :message => "Unable to save document design."}
          return
        end
      end
    end
  end

  def instance
    @document = get_document_by_address(params[:address])
    if request.post?
      if doc_instance = @document.save_instance(params, current_user)
        render :instance_saved, :layout => "document_instance"
      else
        render :layout => "document_instance"
      end
    elsif request.get?
      render :layout => "document_instance"
    end
  end

  def design_delete
    document = fetch_document_for_owner
    document.is_deleted=true
    document.save!
    redirect_to action: 'design_list', status: :found
  end

  def share
    @document = fetch_document_for_owner
    if(params[:share_option] == Document::SHARE_OPTIONS[:email])
      participants = get_emails(params[:share_email_participants]).map do |email|
        Participant.new(:email => email)
      end
      @document.participants = participants
    end
    @document.share_option = params[:share_option]
    @document.save!
    render :json => {:status => :ok}
  end

  private
  def fetch_document_for_owner
    current_user.documents.find(params[:document_id])
  end

  def fetch_fields(doc_id, field_ids)
    document = get_document_by_id(doc_id)
    if(field_ids.nil? || field_ids.size ==0)
      document.fields
    else
      document.fields.where(:id => field_ids)
    end
  end

  def fetch_pictures(doc_id, picture_ids)
    document = get_document_by_id(doc_id)
    if(picture_ids.nil? || picture_ids.size ==0)
      document.pictures
    else
      document.pictures.where(:id => picture_ids)
    end
  end

end
