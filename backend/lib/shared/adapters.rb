DB = Sequel.connect(ENV['DATABASE_URL'])
Sequel.extension :core_extensions
Sequel.extension :migration
DB.extension :pg_array
puts "WARNING: PENDING MIGRATIONS" unless Sequel::Migrator.is_current?(DB, "#{APP_ROOT}/db/migrate")

module Adapters
  require 'shared/adapters/sequel/crud'
  require 'sign_up/infrastructure/users_adapter'
end
