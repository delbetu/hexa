require 'app_helper'
require 'capybara/rspec'
require 'ports'

feature 'User identifies against the system' do
  let(:given_a_user_with_some_permission) do
    authorizer.grant_access(email: 'peter@email.com', permissions: { 'roles' => [:hr] })
  end

  let(:when_he_signs_in_using_the_right_credentials) do
    @result = subject.sign_in(email: 'peter@email.com', password: '1234')
  end

  let(:then_the_app_encodes_user_permissions_as_a_token_and_returns_it) do
    expect(App::Token.decode(@result.token).first['permissions']).to eq('roles' => ['hr'])
  end

  let(:authorizer) {
    instance_double(
      Ports::Authorizer,
      authorize: true,
      grant_access: true,
      get_permissions: { 'roles' => [:hr] }
    )
  }

  subject { App::SignInFlow.new(authorizer: authorizer) }

  scenario 'user provides the right credentials' do
    given_a_user_with_some_permission
    when_he_signs_in_using_the_right_credentials
    then_the_app_encodes_user_permissions_as_a_token_and_returns_it
  end
end
