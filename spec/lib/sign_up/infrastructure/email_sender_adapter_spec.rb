require 'spec_helper'
require 'sign_up/infrastructure/email_sender_adapter'

describe EmailSenderAdapter do
  it 'sends an email' do
    mailer_instance = double('mailer_wrapper_instance', deliver!: nil)
    mail_wrapper = double('MailWrapper', new: mailer_instance)
    stub_const('MailWrapper', mail_wrapper)

    EmailSenderAdapter.send_signup_confirmation(
      invitation_id: 1,
      name: 'Bruce Wayne',
      email: 'bruce@batcave.com'
    )

    expect(mail_wrapper).to have_received(:new).with(
      hash_including(
        from: "no-reply@mydomain.com",
        subject: "Email Confirmation",
        to: "bruce@batcave.com"
      )
    )
    expect(mailer_instance).to have_received(:deliver!)
  end

  it 'instantiates the correct erb template' do
    allow(Templates).to receive(:load_erb)

    EmailSenderAdapter.send_signup_confirmation(
      invitation_id: 1,
      name: 'Bruce Wayne',
      email: 'bruce@batcave.com'
    )

    expect(Templates).to have_received(:load_erb).with('email_confirmation', any_args)
  end
end
