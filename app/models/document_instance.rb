class DocumentInstance < ActiveRecord::Base
  extend Forwardable

  belongs_to :document
  belongs_to :submitted_by, :class_name => "User"

  has_many :field_instances

  def_delegators :document, :can_be_accessed?, :published?, :admin?

end
