require 'shared/adapters/sequel/crud'

module Adapters
  module Users
    extend Adapters::Sequel::Crud
    with(table: :users, array_column: :roles)
  end
end
