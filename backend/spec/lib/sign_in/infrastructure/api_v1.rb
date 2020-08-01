require 'api_persistence_helper'

describe "/sign_in" do
  it 'returns a token which encodes permissions for logged in user' do
    # TODO: use domain factories to ensure valid user
    Persistence::Users.create(
      build_user.with(
        name: 'Batman', email: 'bruce.wayne@gotham.com', password: 'batcave', roles: ['hr']
      ).build
    )

    get '/sign_in', email: 'bruce.wayne@gotham.com', password: 'batcave'

    expect(last_response).to be_ok
    expect(JSON.parse(last_response.body).dig('token')).to eq(Token.encode({'permissions' => ['sign_in', 'sign_up']}))
  end
end
