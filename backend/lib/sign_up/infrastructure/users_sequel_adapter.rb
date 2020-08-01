module Adapters::Users
  extend Adapters::Sequel::Crud
  with(table: :users, array_column: :roles)
end
