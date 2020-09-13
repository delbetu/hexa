require 'securerandom'
require 'shared/adapters/invitations_adapter'
require 'shared/adapters/users_adapter'

class MyAuthorizer
  # TODO: Move to authorizer and test it.
  def self.grant_roles_to_user(email:, roles:)
    user = Adapters::Users.read(filters: [ { email: email } ]).first
    raise "No user found" unless user
    user[:roles] = user[:roles] + roles
    Adapters::Users.update(user)
  end

      # Given an existing user with role guest
      # user = build_user.with(email: 'bruce@gotham.com').with(roles: ['guest']).build
      # Adapters::Users.create(user)
      # grant_roles_to_user(email: user[:email], roles: ['candiate'])
      # expect(Adapters::Users.read.last).to match(
      #   hash_including(
      #     roles: ['guest', 'candidate'],
      #   )
      # )
end

class InvitatorAdapter
  def initialize(authorizer: MyAuthorizer)
    @authorizer = authorizer
  end

  # stores a pending invitation
  # returns generated invitation id
  def invite(email:, roles: )
    invitation = Adapters::Invitations.create(
      email: email, roles: roles, status: 'pending', uuid: SecureRandom.uuid
    )

    invitation[:uuid]
  end

  def confirm(invitation_id:)
    DB.transaction do
      invitations = Adapters::Invitations.read(filters: [uuid: invitation_id])
      invitation = invitations.first
      raise "No invitation found" unless invitation
      invitation[:status] = 'confirmed'
      Adapters::Invitations.update(invitation)

      authorizer.grant_roles_to_user(email: invitation[:email], roles: invitation[:roles])
    end
  end

  def reject(invitation_id:)
    DB[:invitations].where(uuid: invitation_id).delete
  end

  private

  attr_reader :authorizer
end
