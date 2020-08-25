require 'capybara/rspec'
require 'shared/authorization/authorizer'
require 'sign_in/app/flow'

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

  subject { SignInFlow.new(authorizer: authorizer) }

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
