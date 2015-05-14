require 'bcrypt'
class User < ActiveRecord::Base
  include BCrypt

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  def generate_auth_token
    payload = {user_id: self.id}
    AuthHelper::AuthToken.encode(payload)
  end

end
