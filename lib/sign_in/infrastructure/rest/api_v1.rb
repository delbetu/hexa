require 'sinatra'
require "shared/authorization/infrastructure/auth_data_provider_adapter"
require "shared/authorization/authorizer"
require "sign_in/actions/sign_in"

get '/sign_in' do
  # Gather Input ( params, db or external resource)
  email = params[:email]
  password = params[:password]

  # Perform Work
  authorizer = Authorizer.new(authorization_data: AuthDataProviderAdapter)
  use_case = SignIn.new(authenticator: authorizer)
  result = use_case.sign_in(email: params[:email], password: params[:password])

  # Deliver result
  if result.success?
    { token: result.token }
  else # Handle errors
    { errors: result.errors }
  end.to_json
end
