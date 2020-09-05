require 'capybara/rspec'
require 'shared/authorization/authorizer'
require 'sign_in/actions/flow'

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

  subject { SignInFlow.new(authorizer: authorizer) }

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
