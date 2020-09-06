require 'spec_helper'
require 'api_helper'
require 'persistence_helper'
require 'api'

describe 'Sign In' do
  let!(:existing_user) {
    u = build_user.build
    Adapters::Users.create(u)
    u
  }

  it 'generates a token for the user' do
    gql_action_call = %{
      mutation SignIn($email: String!, $password: String!) {
        signIn(email: $email, password: $password) {
          success
          errors
          token
        }
      }
    }

    vars = {
      "email": existing_user[:email],
      "password": 'pass123!',
    }

    post '/graphql', { query: gql_action_call, variables: vars}.to_json

    expect(last_response).to be_ok
    content = JSON.parse(last_response.body)
    expect(content.dig('data', 'signIn', 'success')).to be true
  end
end
