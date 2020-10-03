require 'spec_helper'
require 'sign_up/domain/invitation'

describe Invitation do
  let(:status) { 'confirmed' }
  subject {
    Invitation.new(
      id:     1,
      uuid:   '227c87fc-99b1-4c22-8d39-2a41d6251e4b',
      status: status,
      email: 'some@email.com',
      roles: 'candidate'
    )
  }

  context 'when status is nil' do
    let(:status) { nil }
    it 'defaults to pending' do
      expect(subject.status).to eq('pending')
    end
  end

  it 'raise invalid transaction when trying to set a wrong status' do
    expect {
      subject.status = 'pending'
    }.to raise_error(EndUserError, 'Invitation cannot move from confirmed to pending')

  end

  it 'raise invalid transaction when trying to set a wrong status' do
    expect {
      subject.status = 'rejected'
    }.to raise_error(EndUserError, 'Invitation cannot move from confirmed to rejected')
  end

  it 'raise invalid status when assigning a wrong status' do
    expect {
      subject.status = 'reject'
    }.to raise_error(EndUserError, 'Status must be one of pending, rejected, confirmed')
  end
end
