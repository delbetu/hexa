# Test persistence with test database
require 'sequel_connect'
# TODO: use an in-memory database implementation

RSpec.configure do |config|
  config.around(:each) do |example|
    DB.transaction(:rollback=>:always, :auto_savepoint=>true){example.run}
  end
end
