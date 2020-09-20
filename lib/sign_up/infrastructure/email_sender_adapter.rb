require 'shared/wrappers/mail_wrapper'
require 'shared/templates'

class EmailSenderAdapter

  def self.send_signup_confirmation(invitation_id:, name:, email:)
    body = Templates.load_erb('email_confirmation', {
        confirm_success_url: "#{ENV['BASE_URL']}/email_confirmation?invitation_id=#{invitation_id}",
        confirm_fraud_url: "#{ENV['BASE_URL']}/email_confirmation?invitation_id=#{invitation_id}&reject=true",
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
