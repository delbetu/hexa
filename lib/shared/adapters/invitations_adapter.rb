require 'shared/adapters/sequel/crud'

module Adapters
  module Invitations
    extend Adapters::Sequel::Crud
    with(table: :invitations, json_columns: [:roles])

    def self.find(invitation_id)
      invitations = read(filters: [uuid: invitation_id])
      assert(!invitations.empty?, "No invitation found")
      invitations.first
    end
  end
end
