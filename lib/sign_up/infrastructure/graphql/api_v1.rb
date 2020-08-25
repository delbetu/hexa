require 'sign_up/app/sign_up'
require 'sign_up/infrastructure/user_creator_adapter'

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
      result = ::SignUp.new(creator: UserCreatorAdapter).call(user_attributes)
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
class UserSignUp < GraphQL::Schema::Object
  description "Signup user"

  field :sign_up, mutation: Mutations::SignUp
end

