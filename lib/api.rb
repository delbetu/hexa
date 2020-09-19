require 'sinatra'
require_relative 'sign_in/infrastructure/rest/api_v1'
require_relative 'sign_up/infrastructure/rest/api_v1'
require_relative 'templates_preview_endpoint'

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
module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
  end
end

require 'shared/adapters/users_adapter'
require 'ostruct'

module UsersQuery
  def self.included(child_class)
    child_class.field :users, [Types::User], 'fetch users', null: true
  end

  def users
    Adapters::Users.read
  end
end

module Resolvers
  class Base < GraphQL::Schema::Resolver
    # argument_class Arguments::Base
  end
end
module Resolvers
  class OtherUsersQuery < Resolvers::Base
    type [Types::User], null: true

    def resolve
      Adapters::Users.read
    end
  end
end

class Types::QueryType < GraphQL::Schema::Object
  description "The query root of this schema"
  include UsersQuery
  field :other_users, resolver: Resolvers::OtherUsersQuery, description: 'other users query'
end

require 'sign_up/infrastructure/graphql/api_v1'
require 'sign_in/infrastructure/graphql/api_v1'
class Types::MutationType < GraphQL::Schema::Object
  field :sign_in, mutation: Mutations::SignIn
  field :sign_up, mutation: Mutations::SignUp
end

class GraphqlEndpoint < GraphQL::Schema
  query Types::QueryType
  mutation Types::MutationType
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
