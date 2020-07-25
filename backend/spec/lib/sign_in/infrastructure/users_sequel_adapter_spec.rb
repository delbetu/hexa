require 'persistence_helper'

describe Persistence::Users do
  describe '.read' do
    let!(:user1) {
      Persistence::Users.create(
        build_user.build
      )
    }
    let!(:user2) {
      Persistence::Users.create(
        build_user.with(name: 'Pepe', email: 'my@email.com').build
      )
    }

    it 'fetches all when no args are passed' do
      result = described_class.read
      expect(result.length).to eq(2)
      expect(result).to match_array([ user1, user2 ])
    end

    it 'can filter by name AND email' do
      result = described_class.read(filters: [ { name: 'Pepe', email: 'my@email.com' } ])
      expect(result.length).to eq(1)
      expect(result).to match_array([ user2 ])
    end

    # TODO PENDING support OR on filters
    xit 'can filter by name OR email' do
      result = described_class.read(filters: [ { name: user1['name'] }, { email: user2['email'] } ])
      expect(result.length).to eq(2)
      expect(result).to match_array([ user1, user2 ])
    end

    it 'can paginate' do
      result = described_class.read(pagination: { page: 2, per_page: 1 })
      expect(result.length).to eq(1)
      expect(result).to match_array([ user2 ])
    end

    it 'can be sorted asc' do
      result = described_class.read(sort: [{ attr: 'name' }])
      expect(result.length).to eq(2)
      sorted_names = result.map {|o| o.dig(:name)}
      expect(sorted_names).to match_array([ 'Batman', 'Pepe' ])
    end

    xit 'support no array argument for sorting' do
      result = described_class.read(sort: { attr: 'name' })
      expect(result.length).to eq(2)
      sorted_names = result.map {|o| o.dig(:name)}
      expect(sorted_names).to match_array([ 'Batman', 'Pepe' ])
    end

    it 'can be sorted desc' do
      result = described_class.read(sort: [{ attr: 'name', direction: 'desc' }])
      expect(result.length).to eq(2)
      sorted_names = result.map {|o| o.dig(:name)}
      expect(sorted_names).to match_array([ 'Pepe', 'Batman' ])
    end

    xit 'can include attributes from other tables' do
      result = described_class.read(includes: [])
      expect(result.length).to eq(2)
      sorted_names = result.map {|o| o.dig(:name)}
      expect(sorted_names).to match_array([ 'Pepe', 'Batman' ])
    end
  end

  describe '.create' do
    it 'saves into the database' do
      saved_record = Persistence::Users.create(build_user.with(name: 'Batman', email: 'bruce@batcave.com').build)
      expect(saved_record[:id]).to be_a(Numeric)
      expect(Persistence::Users.read.first[:name]).to eq('Batman')
    end

    it 'fails when wrong attributes' do
      attributes = { name: 'Batman', email: 'bruce@batcave.com', pwd: 'passs' }
      expect {
        Persistence::Users.create(build_user.with(attributes).build)
      }.to raise_error(Persistence::CreateError, /Error creating User with.*passs.*/)
    end
  end

  describe '.update' do
    it 'updates passed attributes' do
      attributes = { name: 'Batman', email: 'bruce@batcave.com' }
      existing_user = Persistence::Users.create(build_user.with(attributes).build)

      result = Persistence::Users.update({ name: 'Bruce' }.merge(id: existing_user[:id]))
      expect(result).to include(name: 'Bruce')
    end

    it 'updates only one row' do
      bob1 = Persistence::Users.create(build_user.with(name: 'Bob').build)
      bob2 = Persistence::Users.create(build_user.with(name: 'Bob', email: 'my@email.com').build)

      result = Persistence::Users.update({ name: 'Bruce' }.merge(id: bob1[:id]))
      expect(Persistence::Users.read(filters: [{name: 'Bruce'}]).count).to eq(1)
    end

    it 'fails when trying to update an non existing attribute' do
      user = Persistence::Users.create(build_user.build)

      expect {
        Persistence::Users.update(id: user[:id], no_existing_attribute: 222)
      }.to raise_error Persistence::UpdateError
    end

    it 'fails when no id is passed' do
      attributes = { name: 'Batman', email: 'bruce@batcave.com' }
      expect {
        Persistence::Users.update(attributes)
      }.to raise_error(Persistence::UpdateError, "id is required for update")
    end

    it 'fails when id does not exists' do
      attributes = {id: 999999, name: 'Batman', email: 'bruce@batcave.com' }

      expect {
        Persistence::Users.update(attributes)
      }.to raise_error(Persistence::UpdateError, "User with id: #{attributes[:id]} not found")
    end
  end

  describe '.delete' do
    it 'deletes passed id' do
      existing_user = Persistence::Users.create(build_user.build)

      Persistence::Users.delete(id: existing_user[:id])
      expect(Persistence::Users.read.count).to eq(0)
    end

    it 'returns deleted user' do
      existing_user = Persistence::Users.create(build_user.build)

      result = Persistence::Users.delete(id: existing_user[:id])
      expect(result).to include({ id: existing_user[:id], name: existing_user[:name] })
    end

    it 'fails when trying to delete an non existing row' do
      expect {
        Persistence::Users.delete(id: 9999999)
      }.to raise_error Persistence::DeleteError, 'User with id: 9999999 not found'
    end

    it 'fails when no id is passed' do
      expect {
        Persistence::Users.delete(name: 2)
      }.to raise_error(ArgumentError)
    end
  end
end
