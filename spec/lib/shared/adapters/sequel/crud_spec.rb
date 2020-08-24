require 'persistence_helper'
require 'shared/adapters/sequel/crud'

module MyResource
  extend Adapters::Sequel::Crud
  with(table: :my_resources, json_columns: [:json_column])
end

describe MyResource do
  before(:all) do
    DB.create_table :my_resources do
      primary_key :id
      String :name, null: false
      Float :price, null: false
      String :json_column, null: true
    end
  end

  after(:all) do
    DB.drop_table :my_resources
  end

  let!(:product1) { { name: 'Product1', price: 100.0, json_column: { some_data: 200 } } }
  let!(:product2) { { name: 'Product2', price: 150.0, json_column: { some_data: 500 } } }

  describe '.read' do
    before do
      MyResource.create(product1)
      MyResource.create(product2)
    end

    it 'fetches all when no args are passed' do
      result = described_class.read
      expect(result.length).to eq(2)
      expect(result[0]).to match(hash_including(name: 'Product1'))
      expect(result[1]).to match(hash_including(name: 'Product2'))
    end

    xit 'serialize/deserialize the columns marked as json_columns' do
      # TODO make this work
      MyResource.create(name: 'Product3', price: 200.0, json_column: { "some_data" => 700 })

      first_result = described_class.read[0]
      expect(first_result).to match(hash_including(json_column: { some_data: 200 }))

      last_result = described_class.read[2]
      expect(last_result).to match(hash_including(json_column: { "some_data" => 700 }))
    end

    it 'can filter by name AND price' do
      result = described_class.read(filters: [ { name: 'Product2', price: 150.0 } ])
      expect(result.length).to eq(1)
      expect(result[0]).to match(hash_including(name: 'Product2'))
    end

    it 'can filter by name OR price' do
      result = described_class.read(filters: [
        { name: 'Product1', price: 100.0 },
        { name: 'Product2', price: 150.0 }
      ])
      expect(result.length).to eq(2)
      expect(result[0]).to match(hash_including(name: 'Product1'))
      expect(result[1]).to match(hash_including(name: 'Product2'))
    end

    it 'can paginate' do
      result = described_class.read(pagination: { page: 2, per_page: 1 })
      expect(result.length).to eq(1)
      expect(result[0]).to match(hash_including(name: 'Product2'))
    end

    it 'can be sorted asc' do
      result = described_class.read(sort: [{ attr: 'name' }])
      expect(result.length).to eq(2)
      sorted_names = result.map {|o| o.dig(:name)}
      expect(sorted_names).to match_array([ 'Product1', 'Product2' ])
    end

    it 'support no array argument for sorting' do
      result = described_class.read(sort: { attr: 'name' })
      expect(result.length).to eq(2)
      sorted_names = result.map {|o| o.dig(:name)}
      expect(sorted_names).to match_array([ 'Product1', 'Product2' ])
    end

    it 'can be sorted desc' do
      result = described_class.read(sort: [{ attr: 'name', direction: 'desc' }])
      expect(result.length).to eq(2)
      sorted_names = result.map {|o| o.dig(:name)}
      expect(sorted_names).to match_array([ 'Product2', 'Product1' ])
    end

    xit 'can include attributes from other tables' do
      result = described_class.read(includes: [])
      expect(result.length).to eq(2)
      sorted_names = result.map {|o| o.dig(:name)}
      expect(sorted_names).to match_array([ 'Product2', 'Product1' ])
    end
  end

  describe '.create' do
    it 'saves into the database' do
      saved_record = MyResource.create(product1)
      expect(saved_record[:id]).to be_a(Numeric)
      expect(MyResource.read.first[:name]).to eq('Product1')
    end

    it 'fails when wrong attributes' do
      expect {
        MyResource.create(product1.merge(no_column: 'some-data'))
      }.to raise_error(CreateError, /Error creating My_resource with.*some-data.*/)
    end
  end

  describe '.update' do
    it 'updates passed attributes' do
      existing_product = MyResource.create(product1)

      result = MyResource.update({ name: 'UpdatedProduct' }.merge(id: existing_product[:id]))
      expect(result).to include(name: 'UpdatedProduct')
    end

    it 'updates only one row' do
      p1 = MyResource.create(product1)
      MyResource.create(product2.merge(name: 'Product1'))

      result = MyResource.update({ name: 'UpdatedProduct' }.merge(id: p1[:id]))
      expect(MyResource.read(filters: [{name: 'UpdatedProduct'}]).count).to eq(1)
    end

    it 'fails when trying to update an non existing attribute' do
      existing_product = MyResource.create(product1)

      expect {
        MyResource.update(id: existing_product[:id], no_existing_attribute: 222)
      }.to raise_error UpdateError
    end

    it 'fails when no id is passed' do
      expect {
        MyResource.update(product1)
      }.to raise_error(UpdateError, "id is required for update")
    end

    it 'fails when id does not exists' do
      attributes = product1.merge(id: 999999)

      expect {
        MyResource.update(attributes)
      }.to raise_error(UpdateError, "My_resource with id: #{attributes[:id]} not found")
    end
  end

  describe '.delete' do
    it 'deletes passed id' do
      existing_product = MyResource.create(product1)

      MyResource.delete(id: existing_product[:id])
      expect(MyResource.read.count).to eq(0)
    end

    it 'returns deleted user' do
      existing_product = MyResource.create(product1)

      result = MyResource.delete(id: existing_product[:id])
      expect(result).to include({ id: existing_product[:id], name: existing_product[:name] })
    end

    it 'fails when trying to delete an non existing row' do
      expect {
        MyResource.delete(id: 9999999)
      }.to raise_error DeleteError, 'My_resource with id: 9999999 not found'
    end

    it 'fails when no id is passed' do
      expect {
        MyResource.delete(name: 2)
      }.to raise_error(ArgumentError)
    end
  end
end
