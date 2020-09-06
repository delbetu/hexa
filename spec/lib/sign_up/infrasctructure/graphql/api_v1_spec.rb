require 'spec_helper'
require 'api_helper'
require 'persistence_helper'
require 'api'
require 'shared/adapters/users_adapter'

describe 'Sign Up' do
  it 'creates user' do
    gql_action_call = %{
      mutation SignUp($name: String!, $email: String!, $password: String!) {
        signUp(name: $name, email: $email, password: $password) {
          success
          errors
        }
      }
    }

    vars = {
      "name": "Adam Smith",
      "email": "adam@email.com",
      "password": "Pass123!",
    }

    post '/graphql', { query: gql_action_call, variables: vars}.to_json

    expect(last_response).to be_ok
    content = JSON.parse(last_response.body)
    expect(content.dig('data', 'signUp', 'success')).to be true
  end
end
