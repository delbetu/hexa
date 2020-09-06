require 'spec_helper'
require 'api_helper'
require 'persistence_helper'
require 'api'
require 'shared/adapters/users_adapter'

describe 'graphql reading users' do
  it 'returns all users' do
    [
      build_user.build,
      build_user.with(name: 'Joker', email: 'joker@hahahahah.com').build
    ].each do |u|
      Adapters::Users.create(u)
    end

    post '/graphql', { query: '{ users { name email } }' }.to_json

    expect(last_response).to be_ok
    content = JSON.parse(last_response.body)
    expect(content.dig('data', 'users', 0, 'name')).to eq('Batman')
    expect(content.dig('data', 'users', 1, 'name')).to eq('Joker')
  end
end
