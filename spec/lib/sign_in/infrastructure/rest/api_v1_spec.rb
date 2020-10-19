# frozen_string_literal: true

require 'spec_helper'
require 'api_helper'
require 'persistence_helper'
require 'sign_in/infrastructure/rest/api_v1'

describe 'GET /sign_in' do
  let(:roles) { %w[hr other] }

  it 'returns a token which encodes permissions for logged in user' do
    Adapters::Users.create(
      build_user.with(
        name: 'Batman', email: 'bruce.wayne@gotham.com', password: encrypt_pwd('batcave'),
        roles: roles
      ).build
    )

    post '/sign_in', { email: 'bruce.wayne@gotham.com', password: 'batcave' }.to_json

    expect(last_response).to be_ok
    decoded_token = Token.decode(JSON.parse(last_response.body)['token'])
    expect(decoded_token).to eq({ 'roles' => roles })
  end
end
