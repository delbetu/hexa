require 'spec_helper'
require 'api_helper'
require 'persistence_helper'
require 'sign_up/infrastructure/invitator_adapter'
require 'sign_up/infrastructure/user_creator_adapter'
require 'sign_up/infrastructure/email_sender_adapter'
require 'sign_up/infrastructure/rest/api_v1'

describe 'POST /users' do
  it 'creates a user' do
    batman = build_user.with(name: 'Batman').build
    json_body = { user: batman }.to_json

    post '/users', json_body, { 'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json' }

    expect(last_response).to be_ok
    content = JSON.parse(last_response.body)
    expect(content.dig('data', 'type')).to eq('users')
    expect(content.dig('data', 'attributes', 'name')).to eq('Batman')

    update_shared_fixture('api/users/create/success.json', last_response)
  end
end

describe 'GET /email_confirmation' do
  let(:invitation) { Adapters::Invitations.read.last }
  # Given an existing user which received an email invitation with a link to confirm it.
  let!(:existing_user) do
    u = build_user.build
    u = ::SignUp
      .new(invitator: InvitatorAdapter.new, creator: UserCreatorAdapter, email_sender: EmailSenderAdapter)
      .call(u)
  end

  # when user click confirm link
  subject do
    get '/email_confirmation', { invitation_id: invitation[:uuid]}
  end

  it 'assign promised(the ones stored in the invitation) roles to user' do
    subject

    updated_user = Adapters::Users.read(filters: [ { id: existing_user.id} ]).first
    expect(updated_user[:roles]).to include(*invitation[:roles])
  end

  it 'redirects the user to login page' do
    subject
    expect(last_response.status).to eq(302)
  end

  # TODO: should test this here?
  context "when user click reject button" do
    xit 'redirects to home page'
    xit 'marks invitation as rejected'
    xit 'doesn not add roles to user'
  end
end
