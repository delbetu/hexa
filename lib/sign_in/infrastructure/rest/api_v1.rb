require 'sinatra'
require "shared/authorization/infrastructure/auth_data_provider_adapter"
require "shared/authorization/authorizer"
require "sign_in/actions/sign_in"

post '/sign_in' do
  # Gather Input ( params, db or external resource)
  data = JSON.parse(request.body.read)
  email = params[:email] || data['email']
  password = params[:password] || data['password']

  # Perform Work
  authorizer = Authorizer.new(authorization_data: AuthDataProviderAdapter)
  use_case = SignIn.new(authenticator: authorizer)
  result = use_case.sign_in(email: email, password: password)

  # Deliver result
  if result.success?
    session['token'] = result.token
    { token: result.token }
  else # Handle errors
    { errors: result.errors }
  end.to_json
end
