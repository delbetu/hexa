require 'capybara/rspec'
require 'load_app'
require 'shared/ports'

feature 'User cannot identify against the system' do
  let(:with_some_permission) do
    authorizer.grant_access(email: 'peter@email.com', permissions: { 'roles' => [:hr] })
  end

  let(:when_he_signs_in_using_malformed_email) do
    @result = subject.sign_in(email: 'peter_at_email.com', password: 'wrong-pass')
  end

  let(:then_the_app_returns_an_error_message) do
    expect(@result.error['messages']).to eq ['Malformed email']
  end

  subject { App::SignInFlow.new(authorizer: authorizer) }

  let(:authorizer) {
    authorizer = instance_double(Ports::Authorizer, grant_access: true)
    authorizer
  }

  scenario 'user provides the wrong credentials' do
    with_some_permission
    when_he_signs_in_using_malformed_email
    then_the_app_returns_an_error_message
  end
end
