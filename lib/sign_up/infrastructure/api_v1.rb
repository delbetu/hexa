require 'sign_up/app/sign_up'
require 'sign_up/infrastructure/user_creator_adapter'
require 'logger'

class UsersSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :email
end

post '/users' do
  body = request.body.read.to_s
  user_attributes = params[:user] || JSON.parse(body)['user'] # accept form data or json

  Logger.new("log/development.log").error("[API user attributes]")
  Logger.new("log/development.log").error(user_attributes)
  new_user = SignUp.call(user_attributes, creator: UserCreatorAdapter)
  UsersSerializer.new(new_user).serialized_json
end
