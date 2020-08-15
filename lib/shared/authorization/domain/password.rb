require 'bcrypt'

# Wrapper around BCrypt
class Password
  def self.encrypt(pwd)
    BCrypt::Password.create(pwd)
  end

  def self.decrypt(pwd_hash)
    BCrypt::Password.new(pwd_hash)
  end
end
