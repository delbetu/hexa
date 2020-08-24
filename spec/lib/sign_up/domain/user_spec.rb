require 'spec_helper'

require 'sign_up/domain/user'

describe Domain::User do
  let(:user_attrs) { build_user.build }

  it 'builds a user from params' do
    result = User(user_attrs)

    expect(result.name).to eq(user_attrs[:name])
    expect(result.email).to eq(user_attrs[:email])
  end

  it 'raise invalid email when email is wrong' do
    expect do
      User(user_attrs.merge(email: 'sss'))
    end.to raise_error EndUserError, "Malformed email"
  end

  it 'raise invalid name when name is wrong' do
    expect do
      User(user_attrs.merge(name: 's'))
    end.to raise_error EndUserError, "Name too short. 2 characters min."
  end

  it 'validates required fields' do
    expect do
      User(user_attrs.except(:email))
    end.to raise_error EndUserError, "email is required"

    expect do
      User(user_attrs.except(:password))
    end.to raise_error EndUserError, "password is required"
  end
end
