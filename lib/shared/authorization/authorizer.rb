# frozen_string_literal: true

require 'shared/authorization/domain/token'
require 'shared/authorization/domain/password'
require 'shared/errors'
require 'shared/authorization/infrastructure/auth_data_provider_adapter'

# Holds user context credentials so it can assess if the user has permissions
class Authorizer
  NotAuthorizedError = Class.new(EndUserError)

  ROLES = %w[hr guest candidate].freeze

  # authorization_data: Crud data source with email, password
  def initialize(authorization_data: AuthDataProviderAdapter)
    @authorization_data = authorization_data
  end

  # Verify that the credentials are legitimate
  # Remembers authenticated user credentials
  def authenticate(email:, password:)
    user = authorization_data.read(filters: [email: email]).first
    assert(!user.nil?, 'Email or password do not match.')

    password_matches = (Password.decrypt(user[:password]) == password)
    assert(password_matches, 'Email or password do not match.')

    @user_context = { id: user[:id], roles: user[:roles] }
  end

  # retrieves and remembers credentials(roles, teams, user_id) for the given user
  def create_user_context(token:)
    decoded = Token.decode(token)
    @user_context = { roles: decoded[:roles] }
  end

  # TODO: rename to user_roles
  def roles
    raise Authorizer::NotAuthorizedError unless @user_context

    @user_context[:roles]
  end

  # TODO: rename to generate token
  def token
    Token.encode({ 'roles' => roles })
  end

  def grant_access(roles: [])
    raise Authorizer::NotAuthorizedError unless @user_context&.[](:id)

    current_roles = @user_context[:roles]
    new_roles = current_roles + roles

    @user_context = authorization_data.update(@user_context.merge(roles: new_roles))
  end

  def grant_roles_to_user(email:, roles:)
    user = authorization_data.read(filters: [{ email: email }]).first
    assert(!user.nil?, 'No user found')

    @user_context = { id: user[:id], roles: user[:roles] + roles }
    grant_access(roles: roles)
  end

  def allow_roles(*required_roles)
    assert(@user_context[:roles].intersection(required_roles).any?, 'Unauthorized')
  end

  private

  attr_reader :authorization_data
end
