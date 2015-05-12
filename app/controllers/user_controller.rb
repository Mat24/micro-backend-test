class UserController < ApplicationController
  def create
    @user = User.new(username: params[:username])
    @user.password = params[:password]
    @user.save!
    render json: {status: :ok}, status: :ok
  end
end
