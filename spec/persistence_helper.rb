# frozen_string_literal: true

# Use an in-memory database implementation

require 'sqlite3'
DB = Sequel.sqlite
$LOAD_PATH << "#{APP_ROOT}/lib"

Sequel.extension :core_extensions
Sequel.extension :migration
Sequel::Migrator.run(DB, "#{APP_ROOT}/db/migrate")

RSpec.configure do |config|
  config.around(:each) do |example|
    DB.transaction(rollback: :always, auto_savepoint: true) { example.run }
  end
end
