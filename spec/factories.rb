require 'bcrypt'

def build_user
  UserBuilder.new
end

# Provides default valid values for User
class UserBuilder
  attr_reader :user

  def initialize
    @user = {
      name: 'Batman',
      email: 'bruce@batcave.com',
      password: UserBuilder.pwd_hash_for(:pass123!),
      roles: ['hr']
    }
  end

  def with(attr_value_hash = {})
    @user.merge!(attr_value_hash)

    self
  end

  def build
    @user
  end

  def self.pwd_hash_for(pwd)
    { pass123!: '$2a$12$MkCyyU7mqYjzKJZ2lS/ckOmYWp3FyV0UwH//T6G0/uod0/x4KnwwK' }[pwd]
  end
end
