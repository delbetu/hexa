require 'sign_up/domain/email_sender_port'
require 'shared/wrappers/mail_wrapper'
require 'shared/templates'

class EmailSenderAdapter
  extend ::EmailSenderPort

  def self.send_signup_confirmation(invitation_id:, name:, email:)
    body = Templates.load_erb('email_confirmation', {
        confirm_success_url: "https://myapp.com/confirm_email?invitation_id=#{invitation_id}",
        confirm_fraud_url: "https://myapp.com/reject_signup?invitation_id=#{invitation_id}",
        name: name
    })

    MailWrapper.new(
      from: 'no-reply@mydomain.com',
      to: email,
      subject: 'Email Confirmation',
      body: body,
    ).deliver!
  end
end
