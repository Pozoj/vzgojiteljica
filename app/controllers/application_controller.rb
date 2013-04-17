class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_section, :body_attrs, :body_id, :body_class, :admin?
  before_filter :authenticate, :except => [:index, :show]

  # Current section accessor.
  def current_section
    @section
  end
  
  def body_id
    "#{controller_name}-#{action_name}"
  end
  
  def body_class
    controller_name
  end

  def body_attrs
    { :class => body_class, :id => body_id }
  end
  
  def get_recent_shouts
    @shouts = Shout.recent
    @shoutbox_nickname = session[:shoutbox_nickname]
  end
  
  def authenticate
    return if signed_in?
    return if devise_controller?
    
    session[:return_to] = request.url
    redirect_to new_user_session_path
  end

  def after_sign_in_path_for resource
    session[:return_to] || root_path
  end
end
