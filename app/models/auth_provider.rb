class AuthProvider < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :uid, :provider, :user
end
