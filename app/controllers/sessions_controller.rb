class SessionsController < ApplicationController
  skip_before_filter :set_current_user

  def new
  end

  def create
    user = User.find_by_email(params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      #log in and redirect to show page
      session[:session_token] = user.session_token
      redirect_to homepage_path
    else
      flash.now[:warning] = 'Incorrect email and/or password'
      render 'new'
    end
  end
end