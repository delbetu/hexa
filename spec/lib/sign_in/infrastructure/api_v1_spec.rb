require 'spec_helper'
require 'api_helper'
require 'persistence_helper'
require 'sign_in/infrastructure/api_v1'

describe "GET /sign_in" do
  it 'returns a token which encodes permissions for logged in user' do
    Adapters::Users.create(
      build_user.with(
        name: 'Batman', email: 'bruce.wayne@gotham.com', password: encrypt_pwd('batcave'), roles: ['hr']
      ).build
    )

    get '/sign_in', email: 'bruce.wayne@gotham.com', password: 'batcave'

    expect(last_response).to be_ok
    expect(JSON.parse(last_response.body).dig('token')).to eq(Token.encode({'permissions' => ['sign_in', 'sign_up']}))
  end
end
