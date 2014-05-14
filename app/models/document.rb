class Document < ActiveRecord::Base
  serialize :value, JSON

  belongs_to :user

  has_many :fields, :dependent => :destroy
  has_many :pictures, :dependent => :destroy
  has_many :file_attachments, :dependent => :destroy
  has_many :admins, :dependent => :destroy
  has_many :participants, :dependent => :destroy


  has_many :document_instances

  scope :active, -> { where(is_deleted: false) }
  scope :order_it, -> { active.order("#{table_name}.created_at desc") }
  scope :no_design, -> { order_it.select(Document.column_names.map { |c| "#{table_name}.#{c}" } - ["#{table_name}.value"]) }

  default_scope { order_it }

  SHARE_OPTIONS = {:none => "none", :url => "url", :email =>"email"}

  after_create do
    self.admins << Admin.create(:email => self.user.email, :document_id => self.id) unless admin?(self.user)
  end

  before_save do
    self.address = SimpleUUID::UUID.new.to_guid if self.address.nil?
  end

  def save_design(design_data)
    return self if design_data.nil?
    design_data = JSON.parse(design_data)

    self.value = design_data["design_struct"]

    save_fields(design_data)
    save_pictures(design_data)

    self.save!
  end

  def self.get_class_for_type(type)
    (type + "_field").classify.constantize
  end

  def design_data_as_json
    {
        :design_struct => self.value,
        :fields => self.fields.map(&:data_as_json),
        :pictures => self.pictures.map(&:data_as_json),
    }.to_json
  end

  def can_be_accessed?(user)
    participant?(user) or admin?(user)
  end

  def admin?(user)
    Admin.where(:email => user.email, :document_id => self.id).exists?
  end

  def participant?(user)
    Participant.where(:email => user.email, :document_id => self.id).exists?
  end

  def validate_document(params)
    valid = true
    fields.each do |field|
      valid = false if not field.validate_field(params["field#{field.id}"])
    end
    valid
  end

  def save_instance(params, user)
    return nil unless validate_document(params)
    document_instance = DocumentInstance.new
    document_instance.document = self
    document_instance.field_instances = fields.map do |field|
      field_instance = FieldInstance.new
      field_instance.value = field.field_instance(params["field#{field.id}"])
      field_instance.design = field.value
      field_instance.field = field
      field_instance
    end

    document_instance.submitted_by = user
    document_instance.save!
    document_instance
  end


  def save_fields(design_data)
    field_ids = self.field_ids
    updated_field_ids = []

    design_data["fields"].each do |field_data|
      if db_id = field_data['db_id']
        field = self.fields.find(db_id)
        updated_field_ids << db_id if db_id
        field.value = field_data
        field.save!
      else
        field = Document.get_class_for_type(field_data["type"]).new
        field.value = field_data
        self.fields << field
      end
    end

    deleted_field_ids = field_ids - updated_field_ids
    Field.delete(deleted_field_ids) if not deleted_field_ids.blank?
  end

  def save_pictures(design_data)
    picture_ids = self.picture_ids
    updated_picture_ids = []

    design_data["pictures"].each do |picture_data|
      if db_id = picture_data['db_id']
        picture = self.pictures.find(db_id)
        updated_picture_ids << db_id if db_id
        picture.value = picture_data
        picture.save!
      else
        picture = Picture.new
        picture.value = picture_data
        self.pictures << picture
      end
    end

    deleted_picture_ids = picture_ids - updated_picture_ids
    Picture.delete(deleted_picture_ids) if not deleted_picture_ids.blank?
  end

end
