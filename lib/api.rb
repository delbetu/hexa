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
class GraphqlEndpoint < GraphQL::Schema
  query UsersQuery
end

require 'rack/contrib'
# use Rack::JSONBodyParser
# use Rack::PostBodyContentTypeParser

post '/graphql' do
  data = JSON.parse(request.body.read)
  logger.info("Graphql data: #{data}")
  result = GraphqlEndpoint.execute(
    data['query'],
    variables: data['variables'],
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
