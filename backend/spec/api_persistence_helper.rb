# Test endpoints end to end

require 'app_helper'
require 'rack/test'

require 'persistence_helper'

require 'load_api_persistence'
def app
  Sinatra::Application.new
end

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.around(:each) do |example|
    DB.transaction(:rollback=>:always, :auto_savepoint=>true){example.run}
  end
end
