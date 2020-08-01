require 'shared/adapters/sequel/crud'

module UserCreatorAdapter
  extend ::Adapters::Sequel::Crud
  with(table: :users, array_column: :roles)
end
