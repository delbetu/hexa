require 'shared/adapters/sequel/crud'

module Adapters
  module Users
    extend Adapters::Sequel::Crud
    with(table: :users, json_columns: [:roles])
  end
end
