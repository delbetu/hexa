# frozen_string_literal: true

require 'sign_in/domain/user_credentials'
require 'shared/errors'
require 'shared/domain/action_result'

class SignIn
  # Inject collaborators dependencies
  def initialize(authenticator: OpenStruct.new(authenticate: false, token: ''))
    @authenticator = authenticator
  end

  def sign_in(email:, password:)
    with_error_handling 'Sign up Error' do
      # Validate Input by Parsing
      user = UserCredentials(email: email, password: password)

      authenticator.authenticate(email: user.email, password: user.password)

      ActionSuccess(token: authenticator.token)
    end
  end

  private

  attr_reader :authenticator
end
