require 'sign_up/domain/user'
require 'sign_up/domain/user_creator_port'
require 'sign_up/domain/invitator_port'
require 'sign_up/domain/email_sender_port'
require 'shared/domain/action_result'
require 'shared/authorization/domain/password'

# Used when a user tries to sign up itself (not inviting others)
# Example: Candidates can sign_up themselves. HRs need invitation from hr team owner.
class SignUp
  # Inject collaborators dependencies
  def initialize(invitator: InvitatorPort, creator: UserCreatorPort, email_sender: EmailSenderPort, roles: ["candidate"])
    @creator = creator
    @invitator = invitator
    @email_sender = email_sender
    @roles = roles
  end

  def call(user_attributes)
    with_error_handling "Sign Up Error" do
      # authorization Anybody can signup

      # Gather data & input parsing
      parsed_user = User(user_attributes)
      parsed_user.password = Password.encrypt(parsed_user.password)

      # Perform Job chain ( in transaction mode )
      assert(!creator.exists?(email: parsed_user.email), 'Email already taken')

      # TODO: intially created without roles is ok. remove 'guest'
      user_created = creator.create(parsed_user.to_h.merge(roles: ['guest']))

      invitation_id = invitator.invite(email: parsed_user.email, roles: roles)

      email_sender.send_signup_confirmation(
        invitation_id: invitation_id,
        name: user_created[:name],
        email: user_created[:email]
      )

      ActionSuccess(user_created.except(:password))
    end
  end

  private

  attr_reader :creator, :email_sender, :roles, :invitator
end
