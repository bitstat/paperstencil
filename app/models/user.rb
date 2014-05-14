class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :omniauthable

  has_many :documents
  has_many :auth_providers

  #attr_accessible :first_name, :last_name

  validates_presence_of :first_name, :last_name

  def demo_user?
    self.email == "demo@paperstencil.com"
  end

  def admin_documents
    Document.no_design.joins(:admins).where("admins.email" => self.email)
  end

  def participating_documents
    Document.no_design.joins(:participants).where("participants.email" => self.email)
  end

  def all_documents
    (admin_documents + participating_documents).compact.uniq
  end

  def name
    "#{last_name} #{first_name}"
  end

  def self.find_by_uid(uid)
    auth = AuthProvider.where(:uid => uid).first
    if auth
      auth.user
    end
  end

  def self.find_for_open_id(access_token)

    user_info = access_token['info'] ? access_token['info'].to_hash : {}
    if user = User.find_by_uid(access_token['uid'])
      user
    else
      user = User.find_by_email(user_info['email']) ||
          User.new(:email      => user_info['email'],
                   :password   => Devise.friendly_token[0, 20],
                   :first_name => extract_first_name(user_info),
                   :last_name  => extract_last_name(user_info))

      auth_provider = AuthProvider.new(:uid => access_token['uid'],
                                       :provider => access_token['provider'])
      auth_provider.user = user
      user.auth_providers << auth_provider
      user.skip_confirmation!
      return user
    end
  end

  def self.extract_first_name(user_info)
    user_info["first_name"] ||
        (user_info["name"] && user_info["name"].split(" ").first) ||
        (user_info["nickname"] && user_info["nickname"].split(" ").first) ||
        " "
  end

  def self.extract_last_name(user_info)
    user_info["first_name"] ||
        (user_info["name"] && user_info["name"].split(" ").last) ||
        (user_info["nickname"] && user_info["nickname"].split(" ").last) ||
        " "
  end

  def open_auth?
    AuthProvider.where(:user_id => self.id).exists?
  end

  # for devise
  def update_with_password(params={})
    if open_auth?
      params.delete(:current_password)
      self.update_without_password(params)
    else
      super
    end
  end

end
