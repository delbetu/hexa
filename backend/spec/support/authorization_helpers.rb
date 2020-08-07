require 'shared/authorization/domain/token'

def token_with_permissions(permission_names)
  Token.encode({ 'permissions' => Array(permission_names) })
end
