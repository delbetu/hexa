require 'securerandom'
require 'shared/adapters/invitations_adapter'
require 'shared/adapters/users_adapter'

class InvitatorAdapter

  # stores a pending invitation
  # returns generated invitation id
  def self.invite(email:, roles: )
    invitation = Adapters::Invitations.create(
      email: email, roles: roles, status: 'pending', uuid: SecureRandom.uuid
    )

    invitation[:uuid]
  end

  def self.invitation_for(email:)

  end

  def self.confirm(invitation_id:)
    DB.transaction do
      invitations = Adapters::Invitations.read(filters: [uuid: invitation_id])
      invitation = invitations.first
      raise "No invitation found" unless invitation
      invitation[:status] = 'confirmed'
      Adapters::Invitations.update(invitation)

      grant_roles_to_user(email: invitation[:email], roles: invitation[:roles])
    end
  end

  # TODO: move to injected collaborator
  def self.grant_roles_to_user(email:, roles:)
    user = Adapters::Users.read(filters: [ { email: email } ]).first
    raise "No user found" unless user
    user[:roles] = user[:roles] + roles
    Adapters::Users.update(user)
  end

  def self.reject(invitation_id:)
    DB[:invitations].where(uuid: invitation_id).delete
  end
end
