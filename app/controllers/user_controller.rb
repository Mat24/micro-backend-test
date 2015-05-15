class UserController < ApplicationController
  before_action :user_params, only: [:create,:update]
  skip_before_action :authenticate_request, only: [:login, :test1]

  def test1
    puts "*******HEADERS*******"
    puts request.headers['Authorization']
    puts "*******USER**********"
    puts @current_user.inspect
    puts "*****************"
    render json: {Jero:{Funciona:"Satan Hpta!"}},status: :ok
  end

  def create
    @user = User.new(user_params)
    @user.password = params[:password]
    @user.save!
    render json: {Usuario: @user}, status: :ok
  end

  def login
    # puts "****************************************"
    # puts params
    # puts "****************************************"
    puts "-------------------------------"
    puts params
    puts "-------------------------------"
    @user = User.find_by_email(params[:email])
    if @user and @user.password == params[:password]
      render json: {auth_token: @user.generate_auth_token, usuario: @user}, status: :accepted
    else
      render json: {error: "usuario y/o contraseña invalidos"}, status: :unauthorized
    end
    # render json: {status:"ok"},status: :ok
  end

  def test
    render json: params, status: :ok
  end

  def update
    @current_user.update(user_params)
    render json: @current_user, status: :ok
  end

  def user_params
    params.permit(:username,:password,:email,:nombre,:apellido,:telefono)
  end
end
