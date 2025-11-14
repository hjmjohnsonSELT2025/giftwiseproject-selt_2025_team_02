class SessionsController < ApplicationController
  skip_before_action :set_current_user

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
  def destroy
    current_user&.reset_session_token!
    session.delete(:session_token)
    redirect_to sign_in_path, notice: "Signed out"
  end
end