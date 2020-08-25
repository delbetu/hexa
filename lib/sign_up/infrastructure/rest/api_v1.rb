require 'sign_up/app/sign_up'
require 'sign_up/infrastructure/user_creator_adapter'

class UsersSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :email
end

class ErrorsSerializer
  include FastJsonapi::ObjectSerializer
  attributes :errors
end

post '/users' do
  body = request.body.read.to_s
  user_attributes = params[:user] || JSON.parse(body)['user'] # accept form data or json

  result = SignUp.new(creator: UserCreatorAdapter).call(user_attributes)

  if result.success?
    UsersSerializer.new(result)
  else
    ErrorsSerializer.new(result)
  end.serialized_json
end
