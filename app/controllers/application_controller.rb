class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  # before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers
  before_action :set_current_user, :authenticate_request

  rescue_from ActionController::RoutingError do
    render json: {error:"Recurso y/o ruta envalida"}, status: 404
  end

  rescue_from AuthHelper::NotAuthenticatedError do
    puts "*******HEADERS*******"
    puts headers
    puts "---------------------"
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
    # headers['Access-Control-Allow-Origin'] = '*'
    # headers['Access-Control-Allow-Methods'] = 'POST, GET'
    # headers['Access-Control-Max-Age'] = "1728000"
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, POST'
    headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
    headers['Content-Type'] = 'application/json'
    headers['Access-Control-Max-Age'] = '86400'
  end

# If this is a preflight OPTIONS request, then short-circuit the
# request, return only the necessary headers and return an empty
# text/plain.

  # def cors_preflight_check
  #   if request.method == :options
  #     headers['Access-Control-Allow-Origin'] = '*'
  #     headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT'
  #     headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version'
  #     headers['Access-Control-Max-Age'] = '1728000'
  #     headers['Access-Control-Allow-Credentials'] = 'true'
  #     render :text => '', :content_type => 'application/json'
  #   end
  # end
end

# class Validador
#   @valores = [3, 7, 13, 17, 19, 23, 29, 37, 41, 43, 47, 53, 59, 67, 71]
#   @acomulador = 0
#   @contador = 0
#   @temporal = 0
#   @documento = 11519462015
#   @tamano = @documento.inspect.length
#   def self.validar
#     @tamano.times do
#       @temporal = ((@tamano - 1) - @contador)
#       @acomulador += @temporal * @valores[@contador]
#       puts "Temporal: #{@temporal}, #{}"
#       @contador.next
#     end
#     puts @acomulador
#   end
# end