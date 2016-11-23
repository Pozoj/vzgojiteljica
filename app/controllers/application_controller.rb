require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_section, :body_attrs, :body_id, :body_class, :admin?
  before_filter :log_request
  before_filter :authenticate
  before_filter :build_filter

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

  def authenticate
    return if signed_in?
    return if devise_controller?

    session[:return_to] = request.url
    redirect_to new_user_session_path
  end

  def after_sign_in_path_for resource
    session[:return_to] || root_path
  end

  def build_filter
    @filter ||= Filter.new params[:filter]
  end

  def log_request
    Scrolls.log(request_data)
  end

  def request_data
    {}.merge(public_request_data).merge(private_request_data).merge(custom_request_data)
  end

  def public_request_data
    {
      at: 'request',
      request_id: request.headers['HTTP_X_REQUEST_ID'],
      method: request.method,
      host: request.host,
      path: request.fullpath,
      referer: request.referer,
      user_agent: request.env['HTTP_USER_AGENT']
    }
  end

  def private_request_data
    return {} unless signed_in?
    {
      user_id: current_user.try(:id),
    }
  end

  def custom_request_data
    {}
  end
end
