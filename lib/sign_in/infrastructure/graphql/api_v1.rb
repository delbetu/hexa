require "shared/authorization/infrastructure/auth_data_provider_adapter"
require "shared/authorization/authorizer"
require "sign_in/actions/sign_in"

module Mutations
  class SignIn < BaseMutation
    description "generates an access token for the given user credentials."
    # Input
    argument :email, String, required: true
    argument :password, String, required: true

    # Output
    field :success?, Boolean, null: false
    field :errors, [String], null: false

    def resolve(email:, password:)
      credentials = { email: email, password: password }

      authorizer = Authorizer.new(authorization_data: AuthDataProviderAdapter)
      use_case = SignIn.new(authenticator: authorizer)
      result = use_case.sign_in(credentials)

      if result.success?
        {
          success: true,
          errors: []
        }
      else
        {
          success: false,
          errors: result.errors
        }
      end
    end
  end
end
class UserSignIn < GraphQL::Schema::Object
  description "SignIn user"

  field :sign_in, mutation: Mutations::SignIn
end

