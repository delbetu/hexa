require 'sinatra'
require_relative 'api/v1/ping'
require_relative 'api/v1/users'
require_relative 'api/v1/sign_in'

before do
  headers 'Access-Control-Allow-Origin' => 'http://localhost:8080'
  headers 'Access-Control-Allow-Origin' => '*'
end
