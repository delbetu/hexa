require 'sinatra'
require_relative 'api/v1/ping'
require_relative 'api/v1/users'
require_relative 'sign_in/infrastructure/api_v1'

before do
  headers 'Access-Control-Allow-Origin' => 'http://localhost:8080'
  headers 'Access-Control-Allow-Origin' => '*'
end
