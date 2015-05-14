class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers
  before_action :set_current_user, :authenticate_request

  rescue_from ActionController::RoutingError do
    render json: {error:"Recurso y/o ruta envalida"}, status: 404
  end

  rescue_from AuthHelper::NotAuthenticatedError do
    render json: {error: "No esta autorizado"}, status: :unauthorized
  end

  rescue_from AuthHelper::AuthenticationTimeoutError do
    render json: {error: "tiempo de sesion agotado"}, status: 419
  end

  private
  def set_current_user
    if decoded_auth_token
      @current_user ||= User.find(decoded_auth_token[:user_id])
    end
  end

  def authenticate_request
    if auth_token_expired?
      fail AuthHelper::AuthenticationTimeoutError
    elsif !@current_user
      fail AuthHelper::NotAuthenticatedError
    end
  end

  def decoded_auth_token
    @decoded_auth_token ||= AuthHelper::AuthToken.decode(http_auth_header_content)
  end

  def auth_token_expired?
    decoded_auth_token && decoded_auth_token.expired?
  end

  def http_auth_header_content
    return @http_auth_header_content if defined? @http_auth_header_content
    @http_auth_header_content = begin
      if request.headers['Authorization'].present?
        request.headers['Authorization'].split(' ').last
      else
        nil
      end
    end
  end

  # Metodos CORS
  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Max-Age'] = "1728000"
  end

# If this is a preflight OPTIONS request, then short-circuit the
# request, return only the necessary headers and return an empty
# text/plain.

  def cors_preflight_check
    if request.method == :options
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version'
      headers['Access-Control-Max-Age'] = '1728000'
      render :text => '', :content_type => 'text/plain'
    end
  end
end