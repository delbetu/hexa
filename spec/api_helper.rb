# Test endpoints end to end
require 'rack/test'

def app
  Sinatra::Application.new
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
