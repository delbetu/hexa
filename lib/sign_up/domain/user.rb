require 'shared/parse_helpers'
require 'shared/errors'

module Domain
  User = Struct.new(:email, :password, :name, keyword_init: true) do
    extend ParseHelpers

    # ensures that user credentials must meet the domain constraints (data and structural)
    def self.parse(attributes)
      email = attributes['email'] || ''
      raise RequiredAttributeError, 'email' if email.empty?

      password = attributes['password'] || ''
      raise RequiredAttributeError, 'password' if password.empty?

      name = attributes['name'] || ''

      new(
        email: parse_email(email),
        password: password,
        name: parse_name(name),
      )
    end

    def [](key)
      to_h[key]
    end
  end
end

def User(attributes)
  Domain::User.parse(attributes.stringify_keys)
end
