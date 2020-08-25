require 'spec_helper'

require 'sign_up/app/sign_up'

describe SignUp do
  let(:user_attrs) { build_user.build }
  let(:fake_creator) { double('creator', create: user_attrs.merge(id: 999), exists?: false) }
  let(:fake_sender) { double('email_sender', send_confirmation: user_attrs.merge(id: 999), exists?: false) }

  subject { SignUp.new(creator: fake_creator, email_sender: fake_sender).call(user_attrs) }

  it 'returns success status' do
    expect(subject.email).to eq(user_attrs[:email])
    expect(subject.success?).to eq(true)
  end

  it 'asks creator to create a user with role guest' do
    subject
    expect(fake_creator).to have_received(:create).with(user_attrs.merge(roles: ['guest']))
  end

  it 'returns the id of the user being created' do
    expect(subject.id).to eq(999)
  end

  it 'sends an email asking for confirmation' do
    subject
    expect(fake_sender).to have_received(:send_confirmation).with(
      id: 999, name: user_attrs[:name], email: user_attrs[:email], roles: ['hr']
    )
  end
end
