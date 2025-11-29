class UsersController < ApplicationController
  skip_before_action :set_current_user, only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(create_user_params)
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
      redirect_to homepage_path
    end
  end
  def edit
    @user = @current_user
    unless current_user?(params[:id])
      flash[:warning] = "Can only edit profile of logged in user!"
      redirect_to homepage_path
    end
  end

  def update
    @user = @current_user
    unless current_user?(params[:id])
      flash[:warning] = "Can only update profile of logged in user!"
      redirect_to homepage_path
      return
    end
    if @user.update(update_user_params)
      redirect_to user_path(@user), notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
  def create_user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def update_user_params
    params.require(:user).permit(:name, :password, :password_confirmation)
  end
end
