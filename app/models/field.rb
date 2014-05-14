class Field < ActiveRecord::Base
  belongs_to :document
  serialize :value, JSON

  attr_accessor :error

  after_create do
    unless value['db_id']
      value['db_id'] = self.id
      self.save
    end
  end

  def validate_field(field)
    raise "Not implemented"
  end

  # should be called after validate_field
  def field_instance(field)
    raise "Not implemented"
  end

  def data_as_json
    value['db_id'] = self.id
    value['has_error'] = self.error ? true : false
    value['error_msg'] = self.error
    value
  end

  #has_many :field_instances, :dependent => :nullify


  def clone_for_template(document)
    dup_field = self.dup
    dup_field.document = document
    dup_field
  end
end
