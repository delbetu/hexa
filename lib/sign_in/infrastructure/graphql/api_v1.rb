# frozen_string_literal: true

require 'shared/authorization/infrastructure/auth_data_provider_adapter'
require 'shared/authorization/domain/token'
require 'shared/authorization/authorizer'
require 'sign_in/actions/sign_in'

module Mutations
  class SignIn < BaseMutation
    null true

    description 'generates an access token for the given user credentials.'
    # Input
    argument :email, String, required: true
    argument :password, String, required: true

    # Output
    field :success, Boolean, null: false
    field :errors, [String], null: false
    field :token, String, null: false

    def resolve(email:, password:)
      credentials = { email: email, password: password }

      use_case = ::SignIn.new(authenticator: context[:authorizer])
      result = use_case.sign_in(**credentials)

      if result.success?
        {
          success: true,
          errors: [],
          token: result.token
        }
      else
        {
          success: false,
          errors: result.errors,
          token: ''
        }
      end
    end
  end
end
