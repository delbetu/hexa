require 'shared/authorization/domain/token'
require 'shared/ports'
require 'bcrypt'

class Authorizer
  NotAuthorizedError = Class.new(StandardError)

  USER_ROLE = { 'bruce.wayne@gotham.com' => [:hr] }.freeze
  ROLES = [:hr].freeze
  FEATURES = [:sign_in, :sign_up].freeze
  PERMISSIONS = {
    hr: [:sign_in, :sign_up],
    candidate: [:apply]
  }.freeze

  # authorization_data: Crud data source with email, password
  def initialize(authorization_data: Adapters::Users)
    @authorization_data = authorization_data
  end

  # Verify that the credentials are legitimate
  # Remembers authorized user
  def authorize(email:, password:)
    encrypted_password = BCrypt::Password.create(password)
    # TODO: filters instead of filter???
    result = authorization_data.read(filter: [email: email, password: encrypted_password])
    raise Authorizer::NotAuthorizedError if result.empty?
    @authorized_user = result.first
  end

  def get_permissions
    raise Authorizer::NotAuthorizedError unless authorized_user
    roles = authorized_user[:roles]

    roles.map { |role| PERMISSIONS[role.to_sym] }.flatten.compact
  end

  def get_token
    Token.encode({ 'permissions' => get_permissions })
  end

  def grant_access(roles: [])
    raise Authorizer::NotAuthorizedError unless authorized_user

    current_roles = authorized_user[:roles]
    new_roles = current_roles + roles

    resulting_roles = authorization_data.update(authorized_user.merge(roles: new_roles))
    self.authorized_user = authorized_user.merge(resulting_roles)
  end

  private

  attr_reader :authorization_data
  attr_accessor :authorized_user
end
