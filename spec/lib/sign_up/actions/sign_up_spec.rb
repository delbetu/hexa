require 'spec_helper'

require 'sign_up/actions/sign_up'

describe SignUp do
  let(:uuid) { '227c87fc-99b1-4c22-8d39-2a41d6251e4b' }
  let(:user_attrs) { build_user.build }
  let(:fake_invitator) { double('invitator', invite: uuid) }
  let(:fake_creator) { double('creator', create: user_attrs.merge(id: 999), exists?: false) }
  let(:fake_sender) { double('email_sender', send_signup_confirmation: user_attrs.merge(id: 999), exists?: false) }

  subject {
    SignUp
      .new(creator: fake_creator, email_sender: fake_sender, invitator: fake_invitator)
      .call(user_attrs)
  }

  it 'returns success status' do
    expect(subject.email).to eq(user_attrs[:email])
    expect(subject.success?).to eq(true)
  end

  it 'tells creator to create a user with role guest' do
    subject
    expect(fake_creator).to have_received(:create).with(
      hash_including(user_attrs.except(:password).merge(roles: ['guest']))
    )
  end

  it 'tells invitator to create a pending invitation' do
    subject
    expect(fake_invitator).to have_received(:invite).with(
      hash_including(email: user_attrs[:email], roles: ['candidate'])
    )
  end

  it 'encrypts the password before saving' do
    allow(Password).to receive(:encrypt)
    subject
    expect(Password).to have_received(:encrypt).with(user_attrs[:password])
  end

  it 'returns the id of the user being created' do
    expect(subject.id).to eq(999)
  end

  it 'sends an email asking for confirmation' do
    subject
    expect(fake_sender).to have_received(:send_signup_confirmation).with(
      invitation_id: uuid, name: user_attrs[:name], email: user_attrs[:email]
    )
  end

  describe 'when email is already taken' do
    let(:user_attrs) { build_user.build }
    let(:fake_creator) {
      double('creator', exists?: true)
    }

    it 'returns failure status' do
      expect(subject.success?).to eq(false)
      expect(subject.errors.first).to match(/Email already taken/)
    end

    it 'asks creator if user already exists' do
      subject
      expect(fake_creator).to have_received(:exists?).with(email: user_attrs[:email])
    end
  end
end
