require 'sign_up/sign_up'

class UsersSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :email
end

post '/users' do
  token = request.env['HTTP_AUTHORIZATION']
  user_attributes = params[:user]
  new_user = SignUp.call(user_attributes, token)
  UsersSerializer.new(new_user).serialized_json
end
