require 'shared/domain/action_result'
require 'sign_up/domain/invitation'

class MyAuthorizer
  # TODO: Merge with existing authorizer and test it.
  def self.grant_roles_to_user(email:, roles:)
    user = Adapters::Users.read(filters: [ { email: email } ]).first
    assert(user.nil?, "No user found")

    user[:roles] = user[:roles] + roles
    Adapters::Users.update(user)
  end

#  describe 'grant_access_to_user' do
#    before do
#      #  Given an existing user with role guest
#      user = build_user.with(email: 'bruce@gotham.com').with(roles: ['guest']).build
#      Adapters::Users.create(user)
#    end
#
#       let(:user_crud) { double('user_crud', read: []) }
#    it 'finds the user and add roles to it in the database' do
#      subject.grant_roles_to_user(email: user[:email], roles: ['candiate'])
#
#      expect(Adapters::Users.read.last).to match(
#        hash_including(
#          roles: ['guest', 'candidate'],
#        )
#      )
#    end
  #    context 'when assigning same role twice' do
  #      it 'duplicate the role' do
  #      end
  #    end
#  end
end

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
