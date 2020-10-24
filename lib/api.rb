# frozen_string_literal: true

require 'sinatra'
require 'shared/authorization/authorizer'
require_relative 'sign_in/infrastructure/rest/api_v1'
require_relative 'sign_up/infrastructure/rest/api_v1'
require_relative 'templates_preview_endpoint'

before do
  headers 'Access-Control-Allow-Origin' => 'http://localhost:8080'
  headers 'Access-Control-Allow-Origin' => '*'
end

require 'securerandom'
enable :sessions
set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }

use Rack::Logger
helpers do
  def logger
    request.logger
  end
end

get '/' do
  'Welcome to Hexa.'
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

####################### Graphql Routes #######################
require 'sign_up/infrastructure/graphql/api_v1'
require 'sign_in/infrastructure/graphql/api_v1'
require_relative 'prototype/job_posts'

class Types::QueryType < GraphQL::Schema::Object
  description 'The query root of this schema'
  include UsersQuery
  field :job_posts, resolver: Resolvers::JobPostsQuery, description: 'other users query'
end

class Types::MutationType < GraphQL::Schema::Object
  field :sign_in, mutation: Mutations::SignIn
  field :sign_up, mutation: Mutations::SignUp
  field :create_job_post, mutation: Mutations::CreateJobPost
  field :update_job_post, mutation: Mutations::UpdateJobPost
  field :delete_job_post, mutation: Mutations::DeleteJobPost
end

class GraphqlEndpoint < GraphQL::Schema
  query Types::QueryType
  mutation Types::MutationType
end

require 'rack/contrib'
# use Rack::JSONBodyParser
# use Rack::PostBodyContentTypeParser

require 'shared/authorization/domain/token'
require 'shared/authorization/infrastructure/auth_data_provider_adapter'
post '/graphql' do
  data = JSON.parse(request.body.read)
  vars = data['variables'] || {}
  logger.info("Graphql data: #{data}")

  # User context is stored on authorizer
  # Which will be inyected into the use cases
  # Each use case perform allow_roles('cadidate', 'hr')
  authorizer = Authorizer.new(authorization_data: AuthDataProviderAdapter)
  authorizer.authenticate_from_token(session[:token])

  result = GraphqlEndpoint.execute(
    data['query'],
    variables: vars,
    context: { authorizer: authorizer }
  )

  if result.to_h.dig('data', 'signIn', 'token')
    session[:token] = result.to_h.dig('data', 'signIn', 'token')
  end

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
