require 'shared/authorization/authorizer'
require 'shared/errors'

module ParseHelpers
  def parse_email(email)
    regexp = /^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$/

    raise EndUserError, "Malformed email" unless email.match(regexp)
    email
  end

  def parse_name(name)
    name = name.to_s
    raise EndUserError, "Name too long. 200 characters max." if name.length > 200
    name
  end

  def parse_roles(roles)
    roles = Array(roles).map(&:to_sym)
    roles.each do |role|
      raise EndUserError, "Role does not exist." unless Authorizer::ROLES.include?(role)
    end

    roles
  end
end
