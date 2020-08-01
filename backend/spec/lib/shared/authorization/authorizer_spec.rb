require 'app_helper'

module App
  describe Authorizer do
    let(:pwd) { '$2a$12$P96rj9YOWNtHwN8lNnq4oOeRO0KMENX1neqDYFSUFw9UbfbKtmeXG' }
    subject { Authorizer.new(authorization_data: user_crud) }

    describe '#authorize' do
      context 'when user doesnt exist with the given credentials' do
        let(:user_crud) { double('user_crud', read: []) }

        it 'raise not-authorized' do
          expect {
            subject.authorize(email: 'bruce.wayne@gotham.com', password: pwd)
          }.to raise_error(App::Authorizer::NotAuthorizedError)
        end
      end

      context 'when user exists with the given credentials' do
        let(:user) { { email: 'bruce.wayne@gotham.com', password: pwd } }
        let(:user_crud) do
          double('user_crud', read: [user])
        end

        it 'stores the authorized user' do
          subject.authorize(email: 'bruce.wayne@gotham.com', password: 'other')

          expect(subject.send(:authorized_user)).to eq(user)
        end
      end
    end

    describe 'get_permissions' do
      let(:user) { { email: 'bruce.wayne@gotham.com', password: pwd, roles: [:hr, :candidate] } }
      let(:user_crud) do
        double('user_crud', read: [user])
      end

      context 'when user is not yet authorized' do
        it 'raise not-authorized' do
          expect {
            subject.get_permissions
          }.to raise_error(App::Authorizer::NotAuthorizedError)
        end
      end

      context 'when user is already authorized' do
        before do
          subject.authorize(email: user[:email], password: user[:password])
        end

        it 'returns a list with all the permissions for all the user roles' do
          stub_const("App::Authorizer::PERMISSIONS", {
            hr: [:feature1, :feature2],
            candidate: [:feature3]
          })

          result = subject.get_permissions

          expect(result).to eq([:feature1, :feature2, :feature3])
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
          expect {
            subject.grant_access
          }.to raise_error(App::Authorizer::NotAuthorizedError)
        end
      end

      context 'when user is already authorized' do
        before do
          subject.authorize(email: user[:email], password: user[:password])
        end

        it 'updates the roles for the authorized user' do
          expect(user_crud).to receive(:update).with(hash_including(roles: existing_roles + new_roles))
          subject.grant_access(roles: new_roles)

          internal_user = subject.send(:authorized_user)
          expect(internal_user[:roles]).to eq(existing_roles + new_roles)
        end
      end
    end
  end
end
