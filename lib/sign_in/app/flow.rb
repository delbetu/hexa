require 'sign_in/domain/user_credentials'
require 'shared/errors'

class SignInFlow
  # Inject collaborators dependencies
  def initialize(authorizer: AuthorizerPort)
    @authorizer = authorizer
  end

  SignInResult = Struct.new(:success, :token, :error) do
    def initialize(success: true, token: '', error: {}); super end
  end

  def sign_in(email:, password:)
    # Validate Input by Parsing
    user = UserCredentials(email: email, password: password)

    authorizer.authenticate(email: email, password: password)

    result = SignInResult.new
    result.token = authorizer.get_token
    result
  rescue Authorizer::NotAuthorizedError, EndUserError => e
    result = SignInResult.new
    result.success = false
    result.error = { 'messages' => [ e.message ] }
    result
  end

  private

  attr_reader :authorizer
end
