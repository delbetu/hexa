require 'shared/parse_helpers'

module Domain
  User = Struct.new(:email, :password, :name, :roles, keyword_init: true) do
    extend ParseHelpers

    # ensures that user credentials must meet the domain constraints (data and structural)
    def self.parse(email:, password: "", name:, roles: [])
      new(
        email: parse_email(email),
        password: password,
        name: parse_name(name),
        roles: parse_roles(roles)
      )
    end

    def [](key)
      to_h[key]
    end
  end
end

def User(attributes)
  Domain::User.parse(**attributes.symbolize_keys)
end
