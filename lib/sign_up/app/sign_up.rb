require 'sign_up/domain/user'
require 'sign_up/domain/user_creator_port'

class EmailSender
  def self.send_confirmation(id:, name:, email:, roles:)
  end
end

class SignUp
  def self.call(user_attributes, creator: UserCreatorPort, email_sender: EmailSender, roles: ["hr"])
    # authorization Anybody can signup

    # gather data & input parsing
    parsed_user = User(user_attributes) # TODO: Get the role from the param, not from user_attributes

    # Perform Job chain ( in transaction mode )
    raise EndUserError, 'Email already taken' if creator.exists?(email: parsed_user.email)

    user_created = creator.create(parsed_user.to_h.merge(roles: ['guest']))

    email_sender.send_confirmation(
      **user_created.except(:password).merge(roles: roles)
    )

    OpenStruct.new(user_created.except(:password).merge(success?: true))

    # error_handling
  rescue EndUserError => e
    OpenStruct.new(id: "Sign Up Error", success?: false, errors: [ e.message ])
  rescue => e
    if (ENV['RACK_ENV'] == 'production')
      Raven.capture_exception(e)
      # End user doesn't receive a stacktrace
      OpenStruct.new(id: "Sign Up Error", success?: false, errors: [ "Error when signing up #{user_attributes}. Please try again later." ])
    else
      raise e # Developer needs to track the issue.
    end
  end
end
