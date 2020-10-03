require 'shared/authorization/domain/token'
require 'shared/authorization/domain/password'
require 'shared/errors'
require 'shared/authorization/infrastructure/auth_data_provider_adapter'

# Wraps an authenticated user
class Authorizer
  NotAuthorizedError = Class.new(EndUserError)

  # TODO: Use string for roles
  USER_ROLE = { 'bruce.wayne@gotham.com' => [:hr] }.freeze
  ROLES = [:hr, :guest].freeze
  FEATURES = [:sign_in, :sign_up].freeze
  PERMISSIONS = {
    hr: [:sign_in, :sign_up],
    candidate: [:apply]
  }.freeze

  # authorization_data: Crud data source with email, password
  def initialize(authorization_data: AuthDataProviderAdapter)
    @authorization_data = authorization_data
  end

  # Verify that the credentials are legitimate
  # Remembers authenticated user
  def authenticate(email:, password:)
    user = authorization_data.read(filters: [email: email]).first
    assert(!user.nil?, "Email or password do not match.")

    password_matches = (Password.decrypt(user[:password]) == password)
    assert(password_matches, "Email or password do not match.")

    @user = user
  end

  def get_permissions
    raise Authorizer::NotAuthorizedError unless user
    roles = user[:roles]

    roles.map { |role| PERMISSIONS[role.to_sym] }.flatten.compact
  end

  def get_token
    Token.encode({ 'permissions' => get_permissions })
  end

  def grant_access(roles: [])
    raise Authorizer::NotAuthorizedError unless user

    current_roles = user[:roles]
    new_roles = current_roles + roles

    resulting_roles = authorization_data.update(user.merge(roles: new_roles))
    self.user = user.merge(resulting_roles)
  end

  def grant_roles_to_user(email:, roles:)
    user = authorization_data.read(filters: [ { email: email } ]).first
    assert(!user.nil?, "No user found")

    @user = user
    grant_access(roles: roles)
  end

  private

  attr_reader :authorization_data
  attr_accessor :user
end
