class DemoController < ApplicationController
  def login
    user = User.find_by_email("demo@paperstencil.com")
    unless user
      user = User.new(:email => "demo@paperstencil.com",
                      :password => "123456",
                      :password_confirmation => "123456",
                      :first_name => "User",
                      :last_name => "Demo",
      )
      user.skip_confirmation!
      user.save!
    end
    sign_in user
    session[:show_demo_guide] = true
    redirect_to user_root_path
  end

  def test_login
    user = User.find_by_email("test@paperstencil.com")
    unless user
      user = User.new(:email => "test@paperstencil.com",
                      :password => "123456",
                      :password_confirmation => "123456",
                      :first_name => "User",
                      :last_name => "Demo",
      )
      user.skip_confirmation!
      user.save!
    end
    sign_in user
    redirect_to user_root_path
  end
end
