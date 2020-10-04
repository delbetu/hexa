require 'spec_helper'

require 'sign_up/actions/confirm_invitation'

describe ConfirmInvitation do
  let(:uuid) { '227c87fc-99b1-4c22-8d39-2a41d6251e4b' }
  let(:args) { { invitation_id: uuid, reject: false } }
  let(:invitation) do
    { id: 1, uuid: uuid, status: 'pending', email: 'some@email.com', roles: ['guest'] }
  end
  let(:fake_invitator) { double('invitator', invite: uuid, find: invitation, update: nil) }
  let(:fake_authorizer) { double('authorizer', grant_roles_to_user: nil) }

  subject do
    ConfirmInvitation
      .new(invitator: fake_invitator, authorizer: fake_authorizer)
      .call(**args)
  end

  it 'returns success status' do
    expect(subject.success?).to eq(true)
  end

  it 'tells invitator to confirm a pending invitation' do
    subject
    expect(fake_invitator).to have_received(:update).with(
      hash_including(uuid: uuid)
    )
  end

  it 'tells authorizer to add role to user with invitation email' do
    subject
    expect(fake_authorizer).to have_received(:grant_roles_to_user)
  end

  context 'when invitation does not exist' do
    before do
      allow(fake_invitator).to receive(:find).and_raise(EndUserError, 'Invitation not found')
    end

    it 'returns failure status' do
      expect(subject.success?).to eq(false)
      expect(subject.errors.first).to match(/Invitation not found/)
    end
  end

  context 'when rejecting invitation' do
    let(:args) { { invitation_id: uuid, reject: true } }

    it 'marks invitation as rejected' do
      expect(fake_invitator).to receive(:update).with(hash_including(status: 'rejected'))
      expect(subject.success?).to eq(true)
    end

    it 'does not grant access to user' do
      expect(fake_authorizer).not_to receive(:grant_roles_to_user)
      expect(subject.success?).to eq(true)
    end
  end
end
