require 'bcrypt'

def build_user
  UserBuilder.new
end

# Provides default valid values for User
class UserBuilder
  attr_reader :user

  def initialize
    @user = { name: 'Batman', email: 'bruce@batcave.com', password: pwd, roles: ['hr'] }
  end

  def with(attr_value_hash = {})
    @user.merge!(attr_value_hash)

    self
  end

  def build
    @user
  end

  private

  def pwd
    BCrypt::Password.create('pass123!')
  end
end
