require 'shared/authorization/domain/password'

def encrypt_pwd(password)
  Password.encrypt(password)
end
