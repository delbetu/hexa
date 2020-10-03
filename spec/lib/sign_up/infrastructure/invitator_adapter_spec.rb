require 'persistence_helper'
require 'sign_up/infrastructure/invitator_adapter'
require 'shared/adapters/invitations_adapter'

# TODO: Implement failure cases
describe InvitatorAdapter do
  describe '#invite' do
    it 'stores a pending invitation' do
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

  describe '#find' do
    let!(:uuid) {
      subject.invite(email: 'bruce@batcave.com', roles: ['candidate'])
    }

    it 'returns invitation when it exists in the database' do
      result = subject.find(invitation_id: uuid)

      expect(result).to match(
        hash_including(
          email: 'bruce@batcave.com',
          roles: ["candidate"],
          status: 'pending',
          uuid: uuid
        )
      )
    end

    # TODO: should find raise an error or should return a Maybe ?
    it 'raise error when it does not exists in the database' do
      expect {
        subject.find(invitation_id: '99999999-9999-9999-9999-999999999999')
      }.to raise_error(EndUserError, 'No invitation found')
    end
  end

  describe '#update' do
    xit 'raise error when it does not exists in the database'

    let!(:invitation) {
      uuid = subject.invite(email: 'bruce@batcave.com', roles: ['candidate'])
      subject.find(invitation_id: uuid)
    }

    it 'updates invitation status' do
      invitation[:status] = 'confirmed'
      result = subject.update(invitation)

      expect(result).to match(
        hash_including(
          email: 'bruce@batcave.com',
          status: 'confirmed'
        )
      )
    end
  end
end
