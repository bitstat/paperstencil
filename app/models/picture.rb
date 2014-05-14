class Picture < ActiveRecord::Base
  belongs_to :document
  serialize :value, JSON

  before_save do
    self.ref_id = self.value["id"] if self.value?
  end

  after_create do
    unless self.value['db_id']
      self.value['db_id'] = self.id
      self.save
    end
  end

  def data_as_json
    value['db_id'] = self.id
    value
  end
end
