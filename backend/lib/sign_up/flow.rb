require 'sign_up/domain/user'

class SignUp
  def self.call(user_attributes, access_token, creator: Persistence::Users)
    # authorization
    decoded_token = App::Token.decode(access_token)
    permissions = decoded_token[0]['permissions']
    raise Ports::Authorizer::NotAuthorizedError unless permissions.include?('sign_up')

    # parsing
    parsed_user = User(user_attributes)

    # error_handling

    OpenStruct.new(Persistence::Users.create(parsed_user.to_h))
  end
end

