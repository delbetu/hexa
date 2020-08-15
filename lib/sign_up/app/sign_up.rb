require 'sign_up/domain/user'
require 'sign_up/domain/user_creator_port'

class SignUp
  def self.call(user_attributes, creator: UserCreatorPort)
    # authorization Anybody can signup

    # parsing
    parsed_user = User(user_attributes)

    # Perform Job chain ( in transaction mode )
    user_created = creator.create(parsed_user.to_h)
    # TODO: send_confirmation_link(user_created) # creates a pending confirmation

    OpenStruct.new(user_created.merge(success?: true))

    # error_handling
  rescue EndUserError => e
    OpenStruct.new(success?: false, errors: e.message)
  rescue => e
    if (ENV['RACK_ENV'] == 'production')
      Raven.capture_exception(e)
      # End user doesn't receive a stacktrace
      OpenStruct.new(success?: false, errors: "Error when signing up #{user_attributes}. Please try again later.")
    else
      raise e # Developer needs to track the issue.
    end
  end
end
