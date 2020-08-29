require 'sinatra'
require_relative 'sign_in/infrastructure/api_v1'
require_relative 'sign_up/infrastructure/rest/api_v1'

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

require 'erb'
# email_confirmation_template = 
# email_confirmation_data = 

# for each file under templates directory
# returns
# {
#   email_confirmation: {
#     erb: File.read('lib/erb_templates/email_confirmation.html.erb'),
#     data: YAML.load_file('lib/erb_templates/email_confirmation.data.yml')
#   }
# }
def templates
  names = Dir['lib/erb_templates/*.html.erb'].map { |f| File.basename(f, ".html.erb") }
  names.inject({}) do |acum, filename|
    acum.merge(
      filename => {
        erb: File.read("lib/erb_templates/#{filename}.html.erb"),
        data: YAML.load_file("lib/erb_templates/#{filename}.data.yml")
      }
    )
  end
end

def index_template
  url_for_names = <<-TEMPLATE
  <ul>
    <% names.each do |name| %>
      <li>
        <a href="/template_preview?name=<%=name%>"><%= name %></a>
      </li>
    <% end %>
  <ul>
TEMPLATE
  {
    erb: url_for_names,
    data: { names: [ 'email_confirmation' ] }
  }
end

get '/template_preview' do
  return 403 if env == 'production'
  template_name = Maybe(params[:name])
  template = templates[template_name] || index_template

  ERB.new(template[:erb]).result_with_hash(template[:data])
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
class UsersQuery < GraphQL::Schema::Object
  description "The query root of this schema"

  field :users, [Types::User], null: true

  def users
    Adapters::Users.read
  end
end

require 'sign_up/infrastructure/graphql/api_v1'
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
