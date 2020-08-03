module ParseHelpers
  def parse_email(email)
    regexp = /^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$/
    raise ArgumentError, "Malformed email" unless email.match(regexp)
    email
  end

  def parse_name(name)
    # TODO: not numbers
    # TODO: max length 100
    name
  end

  def parse_roles(roles)
    # TODO: roles is an array of strings
    # TODO: reject entries that are not present in available roles
    roles
  end

  def parse_password(password)
    # TODO: check that password must be encoded
    password
  end
end
