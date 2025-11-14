class UsersController < ApplicationController
  before_filter :set_current_user, :only => ['show', 'edit', 'update', 'delete']

  def show
    @user = @current_user
    if !current_user?(params[:id])
      flash[:warning] = 'Can only show profile of logged in user!'
    end
  end
end