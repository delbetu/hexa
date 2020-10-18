# frozen_string_literal: true

require 'spec_helper'
require 'shared/authorization/authorizer'
require 'shared/adapters/users_adapter'

class DummyClass
  attr_reader :authorizer

  def initialize(authorizer:)
    @authorizer = authorizer
  end

  def candidate_or_hr_method
    authorizer.allow_roles('candidate', 'hr')
    'success'
  end
end

describe Authorizer do
  let(:pwd_hash) { UserBuilder.pwd_hash_for(:pass123!) }
  subject { Authorizer.new(authorization_data: user_crud) }

  describe '#authenticate' do
    context 'when user doesnt exist with the given credentials' do
      let(:user_crud) { double('user_crud', read: []) }

      it 'raise not-authorized' do
        expect do
          subject.authenticate(email: 'bruce.wayne@gotham.com', password: 'dontcare')
        end.to raise_error(EndUserError, /Email or password do not match/)
      end
    end

    context 'when user exists with the given credentials' do
      let(:user) { { email: 'bruce.wayne@gotham.com', password: pwd_hash } }
      let(:user_crud) do
        double('user_crud', read: [user])
      end

      it 'stores the authorized user' do
        subject.authenticate(email: 'bruce.wayne@gotham.com', password: 'pass123!')

        expect(subject.send(:user)).to eq(user)
      end
    end
  end

  describe 'get_permissions' do
    let(:user) { { email: 'bruce.wayne@gotham.com', password: pwd_hash, roles: %i[hr candidate] } }
    let(:user_crud) do
      double('user_crud', read: [user])
    end

    context 'when user is not yet authorized' do
      it 'raise not-authorized' do
        expect do
          subject.get_permissions
        end.to raise_error(Authorizer::NotAuthorizedError)
      end
    end

    context 'when user is already authorized' do
      before do
        subject.authenticate(email: user[:email], password: 'pass123!')
      end

      it 'returns a list with all the permissions for all the user roles' do
        stub_const('Authorizer::PERMISSIONS', {
                     hr: %i[feature1 feature2],
                     candidate: [:feature3]
                   })

        result = subject.get_permissions

        expect(result).to eq(%i[feature1 feature2 feature3])
      end
    end
  end

  describe 'grant_access' do
    let(:new_roles) { [:hr] }
    let(:existing_roles) { [:candidate] }
    let(:user) { build_user.with(roles: existing_roles).build }
    let(:user_crud) do
      user_crud = double('user_crud', read: [user])
      allow(user_crud).to receive(:update).and_return(roles: existing_roles + new_roles)
      user_crud
    end

    context 'when user is not yet authorized' do
      it 'raise not-authorized' do
        expect do
          subject.grant_access
        end.to raise_error(Authorizer::NotAuthorizedError)
      end
    end

    context 'when user is already authorized' do
      before do
        subject.authenticate(email: user[:email], password: 'pass123!')
      end

      it 'updates the roles for the authorized user' do
        expect(user_crud).to receive(:update)
          .with(hash_including(roles: existing_roles + new_roles))
        subject.grant_access(roles: new_roles)

        internal_user = subject.send(:user)
        expect(internal_user[:roles]).to eq(existing_roles + new_roles)
      end
    end
  end

  describe 'grant_access_to_user' do
    let(:user) { build_user.with(roles: ['guest']).build }
    let!(:user_crud) do
      #  Given an existing user with role guest
      user_crud = double('user_crud', read: [user])
      allow(user_crud).to receive(:update).and_return(roles: %w[cadidate guest])
      user_crud
    end

    it 'finds the user and add roles to it in the database' do
      result = subject.grant_roles_to_user(email: user[:email], roles: ['candidate'])

      expect(result).to match(
        hash_including(
          roles: %w[cadidate guest]
        )
      )
    end

    context 'when assigning same role twice' do
      xit 'does not duplicate the role'
    end
  end

  describe '#allow_roles' do
    let(:authorizer) { Authorizer.new(authorization_data: double('user_crud', read: [user])) }
    before do
      authorizer.authenticate(email: 'bruce.wayne@gotham.com', password: 'pass123!')
    end

    context 'when candidate is authenticated' do
      let(:user) do
        { email: 'bruce.wayne@gotham.com', password: pwd_hash, roles: %w[candidate] }
      end
      it 'allows user to call this method' do
        subject = DummyClass.new(authorizer: authorizer)
        expect(subject.candidate_or_hr_method).to eq('success')
      end
    end

    context 'when hr is authenticated' do
      let(:user) do
        { email: 'bruce.wayne@gotham.com', password: pwd_hash, roles: %w[hr] }
      end
      it 'allows user to call this method' do
        subject = DummyClass.new(authorizer: authorizer)
        expect(subject.candidate_or_hr_method).to eq('success')
      end
    end

    context 'when user with ohter role is authenticated' do
      let(:user) do
        { email: 'bruce.wayne@gotham.com', password: pwd_hash, roles: %w[other] }
      end

      it 'raise Un authorized error' do
        subject = DummyClass.new(authorizer: authorizer)
        expect { subject.candidate_or_hr_method }.to raise_error(EndUserError)
      end
    end
  end
end
