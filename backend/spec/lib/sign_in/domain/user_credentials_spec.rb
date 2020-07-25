require 'app_helper'

describe Domain::UserCredentials do
  subject { UserCredentials(email: 'batman@gotham.com', password: 'batcave') }

  it 'expose its data' do
    expect(subject.email).to eq('batman@gotham.com')
    expect(subject.password).to eq('batcave')
  end

  it 'is possible to read it as a hash' do
    expect(subject[:email]).to eq('batman@gotham.com')
    expect(subject[:password]).to eq('batcave')
  end
end
