require 'sign_up/domain/user'
require 'sign_up/domain/user_creator_port'
require 'sign_up/domain/email_sender_port'
require 'shared/domain/action_result'

class SignUp
  # Inject collaborators dependencies
  def initialize(creator: UserCreatorPort, email_sender: EmailSenderPort, roles: ["hr"])
    @creator = creator
    @email_sender = email_sender
    @roles = roles
  end

  def call(user_attributes)
    # authorization Anybody can signup

    # Gather data & input parsing
    parsed_user = User(user_attributes)

    # Perform Job chain ( in transaction mode )
    assert(!creator.exists?(email: parsed_user.email), 'Email already taken')

    user_created = creator.create(parsed_user.to_h.merge(roles: ['guest']))

    email_sender.send_signup_confirmation(
      **user_created.except(:password).merge(roles: roles)
    )

    ActionSuccess(user_created.except(:password))

    # error_handling
  rescue EndUserError => e
    ActionError(id: "Sign Up Error", errors: [ e.message ])
  rescue => e
    if (ENV['RACK_ENV'] == 'production')
      Raven.capture_exception(e)
      # End user doesn't receive a stacktrace
      ActionError(id: "Sign Up Error", errors: [ "Error when signing up #{user_attributes}. Please try again later." ])
    else # test & Development
      raise e # Developer needs to track the issue.
    end
  end

  private

  attr_reader :creator, :email_sender, :roles
end
