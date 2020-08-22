require 'spec_helper'

require 'sign_up/app/sign_up'

describe SignUp do
  let(:user_attrs) { build_user.build }
  let(:fake_creator) { double('creator', create: user_attrs.merge(id: 999)) }

  subject { SignUp.call(user_attrs, creator: fake_creator) }

  it 'returns success status' do
    expect(subject.email).to eq(user_attrs[:email])
    expect(subject.success?).to eq(true)
  end

  it 'asks creator to create a user' do
    subject
    expect(fake_creator).to have_received(:create).with(user_attrs)
  end

  it 'returns the id of the user being created' do
    expect(subject.id).to eq(999)
  end
end
