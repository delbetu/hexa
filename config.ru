# frozen_string_literal: true

require 'raven'
require 'load_gems'
require 'api'
require 'sequel_connect'

if env != 'production'
  map '/graphiql' do
    run Rack::GraphiQL.new(endpoint: '/graphql')
  end
end

run Sinatra::Application
