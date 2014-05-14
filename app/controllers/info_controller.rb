class InfoController < ApplicationController
  def home
  end

  def pricing
  end

  def us
  end

  def tos
  end

  def privacy
  end

  def google_apps_domain
    if params[:domain] and !params[:domain].to_s.blank?
      redirect_to user_omniauth_authorize_path(:google_apps, :domain => params[:domain])
    else
      flash[:error] = "Google Apps Domain can't be blank"
      redirect_to new_user_session_path
    end
  end
end
