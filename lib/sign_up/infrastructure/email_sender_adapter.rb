require 'shared/wrappers/mail_wrapper'
require 'shared/templates'

class EmailSenderAdapter
  extend ::EmailSenderPort

  def self.send_signup_confirmation(id:, name:, email:, roles:)
    body = Templates.load_erb('email_confirmation', {
        confirm_success_url: 'https://myapp.com/confirm_email?id=96QW$!29AS',
        confirm_fraud_url: 'https://myapp.com/reject_signup?id=96QW$!29AS',
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
