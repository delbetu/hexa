module Domain
  # Struct implements to_h
  # TODO:
  User = Struct.new(:email, :password, :name, :roles, keyword_init: true) do
    extend ParseHelpers

    # ensures that user credentials must meet the domain constraints (data and structural)
    def self.parse(email:, password: "", name:, roles: [])
      new(
        email: parse_email(email),
        password: parse_password(password),
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
  # TODO: extend hash to implement symbolize_keys (same as rails does)
  symbolic_hash = attributes.map { |k, v| [k.to_sym, v]  }.to_h
  Domain::User.parse(symbolic_hash)
end
