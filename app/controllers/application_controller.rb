class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  protect_from_forgery with: :exception

  before_action :set_current_user
  helper_method :current_user, :current_user?, :logged_in?

  protected
  def set_current_user
    @current_user ||= User.find_by_session_token(session[:session_token])
    redirect_to_login_path unless @current_user
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
