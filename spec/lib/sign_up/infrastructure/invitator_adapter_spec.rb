require 'persistence_helper'
require 'sign_up/infrastructure/invitator_adapter'

describe InvitatorAdapter do
  before do
    DB.create_table :invitations do
      primary_key :id
      String :uuid, null: false
      String :status, null: false
      String :email, null: false, unique: true
      String :roles, null: false
    end
    DB.alter_table (:invitations) { set_column_default :roles, "[]" }
  end

  after do
    DB.drop_table :invitations
  end

  it 'stores a pending invitations' do
    allow(SecureRandom).to receive(:uuid).and_return('227c87fc-99b1-4c22-8d39-2a41d6251e4b')

    result = InvitatorAdapter.invite(email: 'bruce@batcave.com', roles: ['candidate'])

    expect(result).to eq('227c87fc-99b1-4c22-8d39-2a41d6251e4b')

    expect(DB[:invitations].all.first).to match(
      hash_including(
        email: 'bruce@batcave.com',
        roles: "[\"candidate\"]",
        status: 'pending',
        uuid: '227c87fc-99b1-4c22-8d39-2a41d6251e4b'
      )
    )
  end
end
