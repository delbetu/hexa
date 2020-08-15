require 'sinatra'
require_relative 'sign_in/infrastructure/api_v1'
require_relative 'sign_up/infrastructure/api_v1'

before do
  headers 'Access-Control-Allow-Origin' => 'http://localhost:8080'
  headers 'Access-Control-Allow-Origin' => '*'
end

get '/' do
  "Welcome to Hexa."
end

error do
  Raven.capture_exception(env['sinatra.error'].message)
  # Server error 5xx
  {
    status: 500,
    errors: [
      {
        code: '5xx',
        title: "Not Found",
        detail: "Entity not found"
      }
    ],
  }.to_json
end

not_found do
  Raven.capture_exception(env['sinatra.error'].message)
  # Client error 4xx
  {
    status: 404,
    errors: [
      {
        code: '4xx',
        title: "Not Found",
        detail: "Entity not found"
      }
    ],
  }.to_json
end
