require 'shared/authorization/authorizer'
require 'shared/errors'

module ParseHelpers
  def parse_email(email)
    assert(!email.nil?, "Email is required.")
    regexp = /^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$/

    raise EndUserError, "Malformed email" unless email.match(regexp)
    email
  end

  def parse_name(name)
    assert(!name.nil?, "Name is required")
    name = name.to_s
    raise EndUserError, "Name too long. 200 characters max." if name.length > 200
    raise EndUserError, "Name too short. 2 characters min." if name.length < 2
    name
  end

  def parse_roles(roles)
    roles = Array(roles)
    roles.each do |role|
      raise EndUserError, "Role does not exist." unless Authorizer::ROLES.include?(role.to_sym)
    end

    roles
  end
end
