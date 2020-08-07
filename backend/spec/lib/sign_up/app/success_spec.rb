require 'spec_helper'
require 'api_helper'
require 'persistence_helper'


describe 'post /users' do
  it 'creates a user' do
    batman = build_user.with(name: 'Batman').build

    header 'Authorization', token_with_permissions('sign_up')
    post '/users', user: batman

    expect(last_response).to be_ok
    content = JSON.parse(last_response.body)
    expect(content.dig('data', 'type')).to eq('users')
    expect(content.dig('data', 'attributes', 'name')).to eq('Batman')

    File.write("#{APP_ROOT}/../shared/fixtures/api/users/create/success.json", JSON.pretty_generate(content))
  end
end
