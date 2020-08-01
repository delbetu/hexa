require 'sign_up/domain/user'

class SignUp
  def self.call(user_attributes, access_token, creator: Adapters::Users)
    # authorization
    decoded_token = Token.decode(access_token)
    permissions = decoded_token[0]['permissions']
    raise Authorizer::NotAuthorizedError unless permissions.include?('sign_up')

    # parsing
    parsed_user = User(user_attributes)

    # error_handling

    OpenStruct.new(creator.create(parsed_user.to_h))
  end
end

