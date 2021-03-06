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
  let(:user) do
    { id: 1, email: 'bruce.wayne@gotham.com', password: pwd_hash, roles: ['hr'] }
  end
  let(:user_crud) { double('user_crud', read: [user]) }

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
      let(:user) { { id: 1, email: 'bruce.wayne@gotham.com', password: pwd_hash, roles: ['hr'] } }
      let(:user_crud) do
        double('user_crud', read: [user])
      end

      it 'stores user credentials' do
        subject.authenticate(email: 'bruce.wayne@gotham.com', password: 'pass123!')

        expect(subject.instance_variable_get(:@user_context)).to eq({ id: 1, roles: ['hr'] })
      end
    end
  end

  describe '#grant_access' do
    let(:new_roles) { ['hr'] }
    let(:existing_roles) { ['candidate'] }
    let(:user) { build_user.with(id: 1, roles: existing_roles).build }
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

        internal_user_context = subject.instance_variable_get(:@user_context)
        expect(internal_user_context[:roles]).to eq(existing_roles + new_roles)
      end
    end
  end

  describe 'grant_access_to_user' do
    let(:user) { build_user.with(id: 1, roles: ['guest']).build }
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

  describe '#authenticate_from_token' do
    it 'decodes token and remembers credentials(roles, teams, user_id)' do
      subject.authenticate_from_token(Token.encode({ id: 1, roles: ['hr'] }))
      expect(subject.instance_variable_get(:@user_context)).to eq({ id: 1, roles: ['hr'] })
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
