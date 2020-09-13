require 'shared/adapters/sequel/crud'

module Adapters
  module Invitations
    extend Adapters::Sequel::Crud
    with(table: :invitations, json_columns: [:roles])
  end
end
