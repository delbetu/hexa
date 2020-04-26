# Test persistence with test database

require 'spec_helper'
require 'load_persistence'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.around(:each) do |example|
    DB.transaction(:rollback=>:always, :auto_savepoint=>true){example.run}
  end
end
