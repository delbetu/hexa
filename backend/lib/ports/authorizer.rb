module Ports
  module Authorizer
    extend Interface
    method(
      :grant_access,
      key_args: {
        permissions: { 'roles' => ['<RoleEnum>'] }
      }
    )
    method(
      :get_permissions,
      # results: ['<PermissionEnum>'] Not supported yet
    )

    # Verify that the credentials are legitimate
    method(:authorize, key_args: { email: '<Email>', password: '<String>' } )

    NotAuthorizedError = Class.new(StandardError)
  end
end
