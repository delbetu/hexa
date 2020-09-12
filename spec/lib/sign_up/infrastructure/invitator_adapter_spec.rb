require 'persistence_helper'
require 'sign_up/infrastructure/invitator_adapter'

# TODO: Implement failure cases
describe InvitatorAdapter do
  describe '#invite' do
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

  describe '#confirm' do
    let!(:existing_uuid) do
      # Given an existing invitation
      InvitatorAdapter.invite(email: 'bruce@batcave.com', roles: ['candidate'])
    end

    it 'confirms the given invitation' do
      InvitatorAdapter.confirm(invitation_id: existing_uuid)

      expect(DB[:invitations].where(uuid: existing_uuid).first).to match(
        hash_including(
          status: 'confirmed',
        )
      )
    end
  end

  describe '#reject' do
    let!(:existing_uuid) do
      # Given an existing invitation
      InvitatorAdapter.invite(email: 'bruce@batcave.com', roles: ['candidate'])
    end

    it 'removes the given invitation' do
      InvitatorAdapter.reject(invitation_id: existing_uuid)

      expect(DB[:invitations].where(uuid: existing_uuid).all).to be_empty
    end
  end
end
