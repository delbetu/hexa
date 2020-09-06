require 'spec_helper'
require 'capybara/rspec'
require 'shared/authorization/authorizer'
require 'sign_in/actions/sign_in'

feature 'User cannot identify against the system' do
  let(:with_some_permission) do
    authorizer.grant_access(roles: [:hr])
  end

  let(:when_he_signs_in_using_the_wrong_credentials) do
    @result = subject.sign_in(email: 'peter@email.com', password: 'wrong-pass')
  end

  let(:then_the_app_returns_an_error_message) do
    expect(@result.errors).to eq ['Invalid email or password.']
  end

  subject { SignIn.new(authenticator: authorizer) }

  let(:authorizer) {
    authorizer = instance_double(Authorizer, grant_access: true)
    allow(authorizer).to receive(:authenticate)
      .with(email: 'peter@email.com', password: 'wrong-pass')
      .and_raise(Authorizer::NotAuthorizedError, 'Invalid email or password.')
    authorizer
  }

  scenario 'user provides the wrong credentials' do
    with_some_permission
    when_he_signs_in_using_the_wrong_credentials
    then_the_app_returns_an_error_message
  end
end

feature 'User cannot identify against the system' do
  let(:with_some_permission) do
    authorizer.grant_access(roles: [:hr])
  end

  let(:when_he_signs_in_using_malformed_email) do
    @result = subject.sign_in(email: 'peter_at_email.com', password: 'wrong-pass')
  end

  let(:then_the_app_returns_an_error_message) do
    expect(@result.errors).to eq ['Malformed email']
  end

  subject { SignIn.new(authenticator: authorizer) }

  let(:authorizer) {
    authorizer = instance_double(Authorizer, grant_access: true)
    authorizer
  }

  scenario 'user provides the wrong credentials' do
    with_some_permission
    when_he_signs_in_using_malformed_email
    then_the_app_returns_an_error_message
  end
end

feature 'User identifies against the system' do
  let(:given_a_user_with_some_permission) do
    authorizer.grant_access(roles: [:hr])
  end

  let(:when_he_signs_in_using_the_right_credentials) do
    @result = subject.sign_in(email: 'peter@email.com', password: '1234')
  end

  let(:then_the_app_encodes_user_permissions_as_a_token_and_returns_it) do
    expect(Token.decode(@result.token).first['permissions']).to eq('roles' => ['hr'])
  end

  let(:authorizer) {
    instance_double(
      Authorizer,
      authenticate: true,
      grant_access: true,
      get_token: Token.encode('permissions' => { 'roles' => ['hr'] })
    )
  }

  subject { SignIn.new(authenticator: authorizer) }

  scenario 'user provides the right credentials' do
    given_a_user_with_some_permission
    when_he_signs_in_using_the_right_credentials
    then_the_app_encodes_user_permissions_as_a_token_and_returns_it
  end
end
