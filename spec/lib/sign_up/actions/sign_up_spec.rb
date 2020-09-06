require 'spec_helper'

require 'sign_up/actions/sign_up'

describe SignUp do
  let(:user_attrs) { build_user.build }
  let(:fake_creator) { double('creator', create: user_attrs.merge(id: 999), exists?: false) }
  let(:fake_sender) { double('email_sender', send_signup_confirmation: user_attrs.merge(id: 999), exists?: false) }

  subject { SignUp.new(creator: fake_creator, email_sender: fake_sender).call(user_attrs) }

  it 'returns success status' do
    expect(subject.email).to eq(user_attrs[:email])
    expect(subject.success?).to eq(true)
  end

  it 'asks creator to create a user with role guest' do
    subject
    expect(fake_creator).to have_received(:create).with(
      hash_including(user_attrs.except(:password).merge(roles: ['guest']))
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
      id: 999, name: user_attrs[:name], email: user_attrs[:email], roles: ['hr']
    )
  end
end

describe SignUp do
  let(:user_attrs) { build_user.build }
  let(:fake_creator) {
    double('creator', exists?: true)
  }

  subject { SignUp.new(creator: fake_creator).call(user_attrs) }

  it 'returns failure status' do
    expect(subject.success?).to eq(false)
    expect(subject.errors.first).to match(/Email already taken/)
  end

  it 'asks creator if user already exists' do
    subject
    expect(fake_creator).to have_received(:exists?).with(email: user_attrs[:email])
  end
end
