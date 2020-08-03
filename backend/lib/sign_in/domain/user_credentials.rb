require 'shared/parse_helpers'

def UserCredentials(params)
  Domain::UserCredentials.new(**params)
end

module Domain
  class UserCredentials
    include ParseHelpers

    attr_accessor :email, :password

    # ensures that user credentials must meet the domain constraints (data and structural)
    def initialize(email:, password:)
      @email = parse_email(email)
      @password = parse_password(password)
    end

    def [](key)
      to_h[key]
    end

    def to_hash
      { email: email, password: password }
    end
    alias to_h to_hash
  end
end
