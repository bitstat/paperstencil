class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  include ApplicationHelper

  skip_before_filter :verify_authenticity_token

  def google_apps; authorize; end
  def yahoo; authorize; end
  def google; authorize; end
  def facebook; authorize; end
  def aol; authorize; end


  private
  def authorize()
    user = User.find_for_open_id(env["omniauth.auth"])
    if user.persisted? or user.save
      set_flash_message(:notice, :success, :kind => OmniAuth::Utils.camelize(env["omniauth.auth"]["provider"]))
      sign_in_and_redirect user, :event => :authentication
    else
      flash[:error] = "Your Auth Provider is not sending the required information. Make sure that your are allowing your provider to send email and name."
      redirect_to root_path
    end
  end
end
