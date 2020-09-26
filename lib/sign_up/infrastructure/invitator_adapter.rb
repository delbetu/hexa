require 'securerandom'
require 'shared/adapters/invitations_adapter'

class InvitatorAdapter
  # stores a pending invitation
  # returns generated invitation id
  def invite(email:, roles: )
    invitation = Adapters::Invitations.create(
      email: email, roles: roles, status: 'pending', uuid: SecureRandom.uuid
    )

    invitation[:uuid]
  end

  def find(invitation_id:)
    Adapters::Invitations.find(invitation_id)
  end

  def update(attrs)
    Adapters::Invitations.update(attrs)
  end
end
