require 'securerandom'

# require 'shared/adapters/invitations_adapter'
require 'sign_up/domain/invitator_port'




require 'shared/adapters/sequel/crud'
module Adapters
  module Invitations
    extend Adapters::Sequel::Crud
    with(table: :invitations, json_columns: [:roles])
  end
end

# TODO: pending to implement
class InvitatorAdapter
  extend ::InvitatorPort

  # stores a pending invitation
  # returns generated invitation id
  def self.invite(email:, roles: )
    invitation = Adapters::Invitations.create(
      email: email, roles: roles, status: 'pending', uuid: SecureRandom.uuid
    )

    invitation[:uuid]
  end

  def self.confirm(invitation_id:)
  end

  def self.reject(invitation_id:)
  end
end
