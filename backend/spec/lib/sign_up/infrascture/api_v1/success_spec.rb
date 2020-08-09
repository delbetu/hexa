require 'spec_helper'
require 'api_helper'
require 'persistence_helper'
require 'sign_up'


describe 'post /users' do
  it 'creates a user' do
    batman = build_user.with(name: 'Batman').build

    post '/users', user: batman

    expect(last_response).to be_ok
    content = JSON.parse(last_response.body)
    expect(content.dig('data', 'type')).to eq('users')
    expect(content.dig('data', 'attributes', 'name')).to eq('Batman')

    update_shared_fixture('api/users/create/success.json', last_response)
  end
end
