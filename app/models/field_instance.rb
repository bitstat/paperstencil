class FieldInstance < ActiveRecord::Base
  belongs_to :document_instance
  belongs_to :field

  serialize :design, JSON
  serialize :value, JSON

  attr_accessor :error
end
