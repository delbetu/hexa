# frozen_string_literal: true

require 'raven'
require 'load_gems'
require 'api'
require 'sequel_connect'

map '/graphiql' do
  run Rack::GraphiQL.new(endpoint: '/graphql')
end

run Sinatra::Application
