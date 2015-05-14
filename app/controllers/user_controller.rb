class UserController < ApplicationController
  before_action :user_params, only: [:create,:update]
  skip_before_action :authenticate_request, only: [:login,:test]

  def test
    render json: {pixel:{x:1,y:2,color:"FFFFFF"}},status: :ok
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

  def update
    @current_user.update(user_params)
    render json: @current_user, status: :ok
  end

  def user_params
    params.permit(:username,:password,:email,:nombre,:apellido,:telefono)
  end
end
