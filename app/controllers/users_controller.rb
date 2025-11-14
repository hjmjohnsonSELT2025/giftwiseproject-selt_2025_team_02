class UsersController < ApplicationController
  before_action :set_current_user, only: %i[show edit update destroy]

  def show
    @user = @current_user
    unless current_user?(params[:id])
      flash[:warning] = 'Can only show profile of logged in user!'
    end
  end
end