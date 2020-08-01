get '/sign_in' do
  # Gather Input ( params, db or external resource)
  email = params[:email]
  password = params[:password]

  # Perform Work
  authorizer = Authorizer.new(authorization_data: Adapters::Users)
  flow = SignInFlow.new(authorizer: authorizer)
  result = flow.sign_in(email: params[:email], password: params[:password])

  # Deliver result
  if result.success
    { token: result.token }
  else # Handle errors
    { error: result.error }
  end.to_json
end
