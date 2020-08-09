require 'sign_up/app/sign_up'
require 'sign_up/infrastructure/user_creator_adapter'

class UsersSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :email
end

post '/users' do
  user_attributes = params[:user]
  new_user = SignUp.call(user_attributes, creator: UserCreatorAdapter)
  UsersSerializer.new(new_user).serialized_json
end
