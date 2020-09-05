require 'spec_helper'

require 'sign_up/actions/sign_up'

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
