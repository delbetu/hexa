require 'sinatra'
require_relative 'sign_in/infrastructure/api_v1'
require_relative 'sign_up/infrastructure/api_v1'

before do
  headers 'Access-Control-Allow-Origin' => 'http://localhost:8080'
  headers 'Access-Control-Allow-Origin' => '*'
end

use Rack::Logger
helpers do
  def logger
    request.logger
  end
end

get '/' do
  "Welcome to Hexa."
end

################################# GRAPHQL #################################
require 'graphql'
module Types
  class BaseObject < GraphQL::Schema::Object
  end

  class User < BaseObject
    description 'Users'

    field :id, ID, null: false
    field :name, String, null: false
    field :email, String, null: true
  end
end

require 'shared/adapters/users_adapter'
require 'ostruct'
class UsersQuery < GraphQL::Schema::Object
  description "The query root of this schema"

  field :users, [Types::User], null: true

  def users
    Adapters::Users.read
  end
end

require 'sign_up/app/sign_up'
require 'sign_up/infrastructure/user_creator_adapter'
module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
  end
  class SignUp < BaseMutation
    description "Creates a user"
    # Input
    argument :name, String, required: true
    argument :email, String, required: true
    argument :password, String, required: true

    # Output
    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(name:, email:, password:)
      user_attributes = { name: name, email: email, password: password }
      result = ::SignUp.call(user_attributes, creator: UserCreatorAdapter)
      if result.success?
        {
          success: true,
          errors: []
        }
      else
        {
          success: false,
          errors: ['Ramdom Error']
        }
      end
    end
  end
end
class UserSignUp < GraphQL::Schema::Object
  description "Signup user"

  field :sign_up, mutation: Mutations::SignUp
end
class GraphqlEndpoint < GraphQL::Schema
  query UsersQuery
  mutation UserSignUp
end

require 'rack/contrib'
# use Rack::JSONBodyParser
# use Rack::PostBodyContentTypeParser

post '/graphql' do
  data = JSON.parse(request.body.read)
  vars = data['variables'] || {}
  logger.info("Graphql data: #{data}")
  result = GraphqlEndpoint.execute(
    data['query'],
    variables: vars,
    context: { current_user: nil  },
  )
  logger.info("Graphql result: #{result.to_h}")
  result.to_json
end
################################# GRAPHQL #################################

# error do
#   Raven.capture_exception(env['sinatra.error'].message)
#   # Server error 5xx
#   {
#     status: 500,
#     errors: [
#       {
#         code: '5xx',
#         title: "Not Found",
#         detail: "Entity not found"
#       }
#     ],
#   }.to_json
# end

# not_found do
#   Raven.capture_exception(env['sinatra.error'].message)
#   # Client error 4xx
#   {
#     status: 404,
#     errors: [
#       {
#         code: '4xx',
#         title: "Not Found",
#         detail: "Entity not found"
#       }
#     ],
#   }.to_json
# end
