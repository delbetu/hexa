require 'sign_up/actions/sign_up'
require 'sign_up/infrastructure/user_creator_adapter'
require 'sign_up/infrastructure/email_sender_adapter'
require 'sign_up/infrastructure/invitator_adapter'

module Mutations
  class SignUp < BaseMutation
    description "Creates a user"
    # Input
    argument :name, String, required: true
    argument :email, String, required: true
    argument :password, String, required: true

    # Output
    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(name:, email:, password:)
      user_attributes = { name: name, email: email, password: password }
      result = ::SignUp
        .new(invitator: InvitatorAdapter, creator: UserCreatorAdapter, email_sender: EmailSenderAdapter)
        .call(user_attributes)
      if result.success?
        {
          success: true,
          errors: []
        }
      else
        {
          success: false,
          errors: result.errors
        }
      end
    end
  end
end
