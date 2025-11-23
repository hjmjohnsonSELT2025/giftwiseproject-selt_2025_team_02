class UsersController < ApplicationController
  before_action :set_current_user, only: %i[show edit update destroy]

  skip_before_action :set_current_user, only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:session_token] = @user.reset_session_token!
      redirect_to homepage_path, notice: "Account created successfully."
    else
      flash[:warning] = "There was a problem creating your account."
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = @current_user
    unless current_user?(params[:id])
      flash[:warning] = "Can only show profile of logged in user!"
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
  
end
