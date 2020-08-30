require 'sign_up/domain/user'
require 'sign_up/domain/user_creator_port'
require 'sign_up/domain/email_sender_port'

class SignUp
  # Inject collaborators dependencies
  def initialize(creator: UserCreatorPort, email_sender: EmailSenderPort, roles: ["hr"])
    @creator = creator
    @email_sender = email_sender
    @roles = roles
  end

  # TODO: create ActionResult = (:success?, :id, :errors, ...other_attrs)
  Result = Struct.new(:success?, :id, :name, :email, :roles, :errors, keyword_init: true)

  def call(user_attributes)
    # authorization Anybody can signup

    # Gather data & input parsing
    parsed_user = User(user_attributes)

    # Perform Job chain ( in transaction mode )
    raise EndUserError, 'Email already taken' if creator.exists?(email: parsed_user.email)

    user_created = creator.create(parsed_user.to_h.merge(roles: ['guest']))

    email_sender.send_signup_confirmation(
      **user_created.except(:password).merge(roles: roles)
    )

    Result.new(user_created.except(:password).merge(success?: true))

    # error_handling
  rescue EndUserError => e
    Result.new(id: "Sign Up Error", success?: false, errors: [ e.message ])
  rescue => e
    if (ENV['RACK_ENV'] == 'production')
      Raven.capture_exception(e)
      # End user doesn't receive a stacktrace
      Result.new(id: "Sign Up Error", success?: false, errors: [ "Error when signing up #{user_attributes}. Please try again later." ])
    else # test & Development
      raise e # Developer needs to track the issue.
    end
  end

  private

  attr_reader :creator, :email_sender, :roles
end
