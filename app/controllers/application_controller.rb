class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery
  include ApplicationHelper

  before_filter :configure_permitted_parameters, if: :devise_controller?

  rescue_from PaperstencilError, :with => :render_error
  def render_error(error)
    @error = error
    respond_to do |format|
      format.html { render :status => @error.status, :file => "shared/error" }
      format.json { render :json => { :status => :fail, :message => @error.message }}
    end
  end

  ## Device
  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    user_session_path
  end

  ## Device
  protected
  def configure_permitted_parameters

    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit :email, :password, :password_confirmation, :first_name, :last_name
    end

    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit :email, :password, :password_confirmation, :current_password, :first_name, :last_name
    end

  end
end




