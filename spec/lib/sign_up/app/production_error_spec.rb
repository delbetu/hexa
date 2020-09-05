require 'spec_helper'

require 'sign_up/actions/sign_up'

describe SignUp do
  let(:user_attrs) { build_user.build }
  let(:fake_creator) { double('creator', create: user_attrs.merge(id: 999), exists?: false) }
  let(:fake_sender) { double('email_sender', send_signup_confirmation: user_attrs.merge(id: 999), exists?: false) }

  subject { SignUp.new(creator: fake_creator, email_sender: fake_sender).call(user_attrs) }

  it 'wraps unhandled errors in production' do
    allow_any_instance_of(Object).to receive(:env).and_return('production')
    allow(Raven).to receive(:capture_exception)
    allow(fake_creator).to receive(:create).and_raise(RuntimeError, "Something bad happened.")

    result = subject

    expect(result.success?).to eq(false)
    expect(result.errors.first).to match(/An error has occured/)
  end
end
