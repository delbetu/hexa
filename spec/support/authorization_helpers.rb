require 'shared/authorization/domain/token'
require 'shared/authorization/domain/password'

def token_with_permissions(permission_names)
  Token.encode({ 'permissions' => Array(permission_names) })
end

def encrypt_pwd(password)
  Password.encrypt(password)
end
