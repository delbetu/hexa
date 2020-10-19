# frozen_string_literal: true

require 'sign_up/actions/sign_up'
require 'sign_up/actions/confirm_invitation'
require 'sign_up/infrastructure/invitator_adapter'
require 'shared/authorization/authorizer'
require 'shared/authorization/infrastructure/auth_data_provider_adapter'
require 'sign_up/infrastructure/user_creator_adapter'
require 'sign_up/infrastructure/email_sender_adapter'

class UsersSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :email
end

class ErrorsSerializer
  include FastJsonapi::ObjectSerializer
  attributes :errors
end

# TODO: add rack body parser middleware
# require 'rack-contrib'
# use Rack::PostBodyContentTypeParser
post '/users' do
  body = request.body.read.to_s
  user_attributes = params[:user] || JSON.parse(body)['user'] # accept form data or json

  result = SignUp.new(
    invitator: InvitatorAdapter.new,
    creator: UserCreatorAdapter,
    email_sender: EmailSenderAdapter
  ).call(user_attributes)

  if result.success?
    UsersSerializer.new(result)
  else
    ErrorsSerializer.new(result)
  end.serialized_json
end

get '/email_confirmation' do
  invitation_id = params['invitation_id'] || 'TODO: return error'
  # what happens if the invitation id doesn't exists
  reject = params['reject'] == 'true' || false

  authorizer = Authorizer.new(authorization_data: AuthDataProviderAdapter)

  result = ConfirmInvitation
           .new(invitator: InvitatorAdapter.new, authorizer: authorizer)
           .call(invitation_id: invitation_id, reject: reject)

  if result.success?
    redirect to('/')
  else
    redirect to('/500.html')
  end
end
