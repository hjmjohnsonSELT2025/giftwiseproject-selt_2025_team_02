class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  protect_from_forgery with: :exception

  before_action :set_current_user
  helper_method :current_user, :current_user?, :logged_in?

  # Catch errors when a record is not found
  rescue_from ActiveRecord::RecordNotFound, with: :handle_missing_record
  def handle_routing_error
    flash[:alert] = "The page you are looking for does not exist."
    redirect_to root_path
  end

  private
  def set_current_user
    @current_user = User.find_by(session_token: session[:session_token])
    redirect_to login_path unless @current_user
  end

  # Calls this when someone deletes a record (gift or recipient) and they try to retrieve that route again (back button)
  def handle_missing_record
    flash[:alert] = "The page or record you are looking for doesn't exist"
    redirect_to root_path
  end

  def current_user
    @current_user
  end
  def current_user?(id)
    @current_user.id.to_s == id
  end

  def logged_in?
    current_user.present?
  end
end
