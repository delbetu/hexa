require 'persistence_helper'
require 'sign_up/infrastructure/invitator_adapter'
require 'shared/adapters/users_adapter'
require 'shared/adapters/invitations_adapter'

# TODO: Implement failure cases
describe InvitatorAdapter do
  describe '#invite' do
    it 'stores a pending invitations' do
      allow(SecureRandom).to receive(:uuid).and_return('227c87fc-99b1-4c22-8d39-2a41d6251e4b')

      result = subject.invite(email: 'bruce@batcave.com', roles: ['candidate'])

      expect(result).to eq('227c87fc-99b1-4c22-8d39-2a41d6251e4b')

      expect(Adapters::Invitations.read.first).to match(
        hash_including(
          email: 'bruce@batcave.com',
          roles: ["candidate"],
          status: 'pending',
          uuid: '227c87fc-99b1-4c22-8d39-2a41d6251e4b'
        )
      )
    end
  end

  describe '#confirm' do
    let(:fake_authorizer) { double('authorizer', grant_roles_to_user: nil) }
    subject { InvitatorAdapter.new(authorizer: fake_authorizer) }

    let!(:existing_uuid) do
      # Given an existing user with role guest and pending invitation
      user = build_user.with(email: 'bruce@gotham.com').with(roles: ['guest']).build
      subject.invite(email: user[:email], roles: ['candidate'])
    end

    xit 'error when user not exists'
    xit 'error when invitation not exists'

    it 'confirms the given invitation' do
      subject.confirm(invitation_id: existing_uuid)

      expect(
        Adapters::Invitations.read(filters: [{ uuid: existing_uuid }]).first
      ).to match(
        hash_including(
          status: 'confirmed'
        )
      )
    end

    it 'tells user updater to grant requested role to the user' do
      subject.confirm(invitation_id: existing_uuid)

      expect(fake_authorizer).to have_received(:grant_roles_to_user)
        .with(email: 'bruce@gotham.com', roles: ['candidate'])

    end
  end

  describe '#reject' do
    let!(:existing_uuid) do
      # Given an existing invitation
      subject.invite(email: 'bruce@batcave.com', roles: ['candidate'])
    end

    it 'removes the given invitation' do
      subject.reject(invitation_id: existing_uuid)

      expect(Adapters::Invitations.read).to be_empty
    end
  end
end
