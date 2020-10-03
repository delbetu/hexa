require 'shared/domain/action_result'
require 'sign_up/domain/invitation'

class ConfirmInvitation
  # Inject collaborators dependencies
  def initialize(invitator:, authorizer: Authorizer.new)
    @invitator = invitator
    @authorizer = authorizer
  end

  def call(invitation_id:, reject:)
    with_error_handling "Confirm Invitation Error" do
      # authorization anybody with the link can confirm invitation

      # Gather data & input parsing
      invitation_attrs = invitator.find(invitation_id)

      # Perform Job chain ( in transaction mode )
      invitation = Invitation.new(**invitation_attrs)
      new_status = reject ? 'rejected' : 'confirmed'
      invitation.status = new_status

      # transaction do
      invitator.update(invitation.to_h)
      authorizer.grant_roles_to_user(email: invitation.email, roles: invitation.roles)
      # end

      ActionSuccess()
    end
  end

  private

  attr_reader :invitator, :authorizer
end
