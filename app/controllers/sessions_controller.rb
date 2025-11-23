class SessionsController < ApplicationController
  skip_before_action :set_current_user, only: %i[new create google_auth]
  def new
  end

  def create
    user = User.find_by(email: params.dig(:session, :email))
    if user&.authenticate(params.dig(:session, :password))
      session[:session_token] = user.reset_session_token!
      redirect_to homepage_path, notice: "Logged in!"
    else
      flash.now[:warning] = "Incorrect email and/or password"
      render :new, status: :unprocessable_entity
    end
  end

  def google_auth
    # get user information
    auth_info = request.env["omniauth.auth"]
    email = auth_info.dig("info", "email")
    name = auth_info.dig("info", "name") || email

    user = User.find_by(email: email)

    # if not already in use, create new user
    unless user
      # won't actually be used, user will have to log-in via google
      fake_password = SecureRandom.hex(12)
      user = User.new(
        name: name,
        email: email.downcase,
        password: fake_password,
        password_confirmation: fake_password)
      unless user.save
        flash[:warning] = "Could not create an account from your Google credentials"
        return redirect_to login_path
      end
    end

    session[:session_token] = user.reset_session_token!
    redirect_to homepage_path, notice: "Logged in via Google"
  end
  
  def destroy
    current_user&.reset_session_token!
    session.delete(:session_token)
    redirect_to login_path, notice: "Signed out"
  end
end
