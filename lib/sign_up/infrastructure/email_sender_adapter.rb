require 'sign_up/domain/email_sender_port'
require 'sign_up/domain/pending_confirmation_port'
require 'shared/wrappers/mail_wrapper'
require 'shared/templates'

class EmailSenderAdapter
  extend ::EmailSenderPort

  def self.send_signup_confirmation(id:, name:, email:, roles:)
    pending_confirmation = PendingConfirmationPort.create!(user_id: id, roles: roles)

    body = Templates.load_erb('email_confirmation', {
        confirm_success_url: "https://myapp.com/confirm_email?id=#{pending_confirmation.id}",
        confirm_fraud_url: "https://myapp.com/reject_signup?id=#{pending_confirmation.id}",
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
