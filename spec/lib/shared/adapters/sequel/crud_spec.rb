# frozen_string_literal: true

require 'persistence_helper'
require 'shared/adapters/sequel/crud'

module MyResource
  extend Adapters::Sequel::Crud
  with(table: :my_resources, json_columns: [:json_column])
  # TODO: pending support different id column.
  # say I want to perform find and update by uuid or email instead of id
  # then I specify in this resource
  # "identifier_colum :uuid" and the operations use this attribute
end

describe MyResource do
  before(:all) do
    DB.create_table :my_resources do
      primary_key :id
      String :name, null: false
      Float :price, null: false
      String :json_column, null: true
      Integer :created_by, null: false
    end
  end

  after(:all) do
    DB.drop_table :my_resources
  end

  let(:owner_id) { 1 }
  let!(:product1) do
    { name: 'Product1', price: 100.0, json_column: { some_data: 200 }, created_by: owner_id }
  end

  let!(:product2) do
    { name: 'Product2', price: 150.0, json_column: { some_data: 500 }, created_by: owner_id }
  end

  xit 'support different identifier columns'
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
      # TODO: make this work
      MyResource.create(name: 'Product3', price: 200.0, json_column: { 'some_data' => 700 })

      first_result = described_class.read[0]
      expect(first_result).to match(hash_including(json_column: { some_data: 200 }))

      last_result = described_class.read[2]
      expect(last_result).to match(hash_including(json_column: { 'some_data' => 700 }))
    end

    it 'can filter by name AND price' do
      result = described_class.read(filters: [{ name: 'Product2', price: 150.0 }])
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
      sorted_names = result.map { |o| o[:name] }
      expect(sorted_names).to match_array(%w[Product1 Product2])
    end

    it 'support no array argument for sorting' do
      result = described_class.read(sort: { attr: 'name' })
      expect(result.length).to eq(2)
      sorted_names = result.map { |o| o[:name] }
      expect(sorted_names).to match_array(%w[Product1 Product2])
    end

    it 'can be sorted desc' do
      result = described_class.read(sort: [{ attr: 'name', direction: 'desc' }])
      expect(result.length).to eq(2)
      sorted_names = result.map { |o| o[:name] }
      expect(sorted_names).to match_array(%w[Product2 Product1])
    end

    xit 'can include attributes from other tables' do
      result = described_class.read(includes: [])
      expect(result.length).to eq(2)
      sorted_names = result.map { |o| o[:name] }
      expect(sorted_names).to match_array(%w[Product2 Product1])
    end
  end

  describe '.create' do
    it 'saves into the database' do
      saved_record = MyResource.create(product1)
      expect(saved_record[:id]).to be_a(Numeric)
      expect(MyResource.read.first[:name]).to eq('Product1')
    end

    it 'fails when wrong attributes' do
      expect do
        MyResource.create(product1.merge(no_column: 'some-data'))
      end.to raise_error(CreateError, /Error creating My_resource with.*some-data.*/)
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

      MyResource.update({ name: 'UpdatedProduct' }.merge(id: p1[:id]))
      expect(MyResource.read(filters: [{ name: 'UpdatedProduct' }]).count).to eq(1)
    end

    it 'fails when trying to update an non existing attribute' do
      existing_product = MyResource.create(product1)

      expect do
        MyResource.update(id: existing_product[:id], no_existing_attribute: 222)
      end.to raise_error UpdateError
    end

    it 'fails when no id is passed' do
      expect do
        MyResource.update(product1)
      end.to raise_error(UpdateError, 'id is required for update')
    end

    it 'fails when id does not exists' do
      attributes = product1.merge(id: 999_999)

      expect do
        MyResource.update(attributes)
      end.to raise_error(UpdateError, "My_resource with id: #{attributes[:id]} not found")
    end

    describe 'can include a scope' do
      let(:owner_accessing) do
        { created_by: owner_id }
      end
      let(:non_owner_accessing) do
        { created_by: owner_id + 999 }
      end
      let!(:p1) { MyResource.create(product1) }

      context 'when owner is trying to update' do
        it 'is updated correctly' do
          new_attrs = { name: 'UpdatedProduct' }.merge(id: p1[:id])

          result = MyResource.update(new_attrs, scope: owner_accessing)

          expect(result[:name]).to eq('UpdatedProduct')
          expect(MyResource.read(filters: [{ name: 'UpdatedProduct' }]).count).to eq(1)
        end
      end

      context 'when non owner is trying to update' do
        it 'raise an error' do
          new_attrs = { name: 'UpdatedProduct' }.merge(id: p1[:id])

          expect do
            MyResource.update(new_attrs, scope: non_owner_accessing)
          end.to raise_error(UpdateError, /Scope rule not met/)

          expect(MyResource.read(filters: [{ name: 'UpdatedProduct' }]).count).to eq(0)
        end
      end
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
      expect do
        MyResource.delete(id: 9_999_999)
      end.to raise_error DeleteError, 'My_resource with id: 9999999 not found'
    end

    it 'fails when no id is passed' do
      expect do
        MyResource.delete(name: 2)
      end.to raise_error(ArgumentError)
    end

    describe 'can include a scope' do
      let(:owner_accessing) do
        { created_by: owner_id }
      end
      let(:non_owner_accessing) do
        { created_by: owner_id + 999 }
      end
      let!(:p1) { MyResource.create(product1) }

      context 'when owner is trying to delete' do
        it 'is updated correctly' do
          MyResource.delete(id: p1[:id], scope: owner_accessing)
          expect(MyResource.read(filters: [{ id: p1[:id] }]).count).to eq(0)
        end
      end

      context 'when non owner is trying to delete' do
        it 'raise an error' do
          expect do
            MyResource.delete(id: p1[:id], scope: non_owner_accessing)
          end.to raise_error(DeleteError, /Scope rule not met/)
          expect(MyResource.read(filters: [{ id: p1[:id] }]).count).to eq(1)
        end
      end
    end
  end
end
