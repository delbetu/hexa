require 'sign_up/domain/user'
require 'sign_up/domain/user_creator_port'
require 'logger'

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
      # TODO: Report error to AppMonitor
      logger = Logger.new("#{APP_ROOT}/log/development.log")
      logger.error("[SignUp] Unhandled error happened ")
      logger.error(e.message)
      logger.error(e.backtrace)
      OpenStruct.new(success?: false, errors: e.message)
    else
      raise e
    end
  end
end