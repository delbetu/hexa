require 'capybara/rspec'
require 'load_app'
require 'ports'

feature 'User cannot identify against the system' do
  let(:with_some_permission) do
    authorizer.grant_access(email: 'peter@email.com', permissions: { 'roles' => [:hr] })
  end

  let(:when_he_signs_in_using_the_wrong_credentials) do
    @result = subject.sign_in(email: 'peter@email.com', password: 'wrong-pass')
  end

  let(:then_the_app_returns_an_error_message) do
    expect(@result.error['messages']).to eq ['Invalid email or password.']
  end

  subject { App::SignInFlow.new(authorizer: authorizer) }

  let(:authorizer) {
    authorizer = instance_double(Ports::Authorizer, grant_access: true)
    allow(authorizer).to receive(:authorize)
      .with(email: 'peter@email.com', password: 'wrong-pass')
      .and_raise(Ports::Authorizer::NotAuthorizedError, 'Invalid email or password.')
    authorizer
  }

  scenario 'user provides the wrong credentials' do
    with_some_permission
    when_he_signs_in_using_the_wrong_credentials
    then_the_app_returns_an_error_message
  end
end
