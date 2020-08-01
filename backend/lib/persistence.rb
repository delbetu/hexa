DB = Sequel.connect(ENV['DATABASE_URL'])
Sequel.extension :core_extensions
Sequel.extension :migration
DB.extension :pg_array
puts "WARNING: PENDING MIGRATIONS" unless Sequel::Migrator.is_current?(DB, "#{APP_ROOT}/db/migrate")

module Persistence
  class Error < StandardError; end
  class CreateError < Error; end
  class UpdateError < Error; end
  class DeleteError < Error; end

  require 'shared/generic_crud_sequel_adapter'
  require 'sign_up/infrastructure/users_sequel_adapter'
end
