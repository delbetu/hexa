# frozen_string_literal: true

require 'shared/errors'

module Adapters
  module Sequel
    module Crud
      def with(table:, json_columns: [])
        @table = table.freeze
        @json_columns = json_columns.freeze
      end

      def entity_name
        @table.to_s.singularize.capitalize
      end

      def create(attributes)
        attributes = serialize_json_columns(attributes, @json_columns).symbolize_keys

        id = DB[@table].insert(attributes)
        attributes[:id] = id
        attributes
      rescue ::Sequel::DatabaseError => e
        # Log errr and avoid user to receive it
        logger = Logger.new('log/development.log')
        logger.error(e.message)
        logger.error(e.backtrace)
        Raven.capture_exception(e)
        raise CreateError, "Error creating #{entity_name} with #{attributes}"
      end

      def read(options = {})
        result = DB[@table]

        if !!options[:filters]
          # [{ name: 'a' }] => result.where(name: 'a')
          # [{ name: 'a' , price: 50}] => result.where(name: 'a', price: 50)
          # [{ name: 'a' , price: 50}, {price: 100}] => result.where(name: 'a', price: 50).or(price: 100)
          first_condition = options[:filters].pop
          rest = options[:filters]

          result = result.where(first_condition)
          rest.each do |condition|
            result = result.or(condition)
          end
        end

        if !!options[:pagination]
          page = options.dig(:pagination, :page) || 1
          per_page = options.dig(:pagination, :per_page) || 10
          offset = (page - 1) * per_page
          result = result.limit(per_page).offset(offset)
        end

        if !!options[:sort]
          sort_attributes = options[:sort].is_a?(Array) ? options[:sort] : [options[:sort]]

          sort_attributes.each do |sort_option|
            attr = sort_option[:attr]
            direction = sort_option[:direction]
            raise('attr must be present') unless attr

            order =
              if direction.to_s.strip.casecmp('desc')
                ::Sequel.desc(attr.to_sym)
              else
                ::Sequel.asc(attr.to_sym)
              end

            result = result.order(order)
          end
        end

        # TODO: Include total number on result and the fetched number
        # so we can do: showing 10 of 1892
        deserialize_collection(result.all, @json_columns)
      end

      # returns only the affected attributes
      def update(attributes)
        id = attributes.delete(:id)
        raise UpdateError, 'id is required for update' unless id

        attributes = serialize_json_columns(attributes, @json_columns)

        affected_rows = DB[@table].where(id: id).update(attributes)
        raise UpdateError, "#{entity_name} with id: #{id} not found" if affected_rows.zero?

        attributes[:id] = id
        attributes
      rescue ::Sequel::DatabaseError => e
        raise UpdateError, "Error updating #{entity_name} with #{attributes}"
      end

      def delete(id:)
        row_to_delete = DB[@table].where(id: id).first
        affected_rows = DB[@table].where(id: id).delete
        raise DeleteError, "#{entity_name} with id: #{id} not found" if affected_rows.zero?

        row_to_delete
      rescue ::Sequel::DatabaseError => e
        raise DeleteError, "Error deleting #{entity_name} with #{attributes}"
      end

      private

      def serialize_json_columns(hash, json_columns)
        hash = hash.clone # do not mutate parameter
        json_columns.each do |col|
          next unless hash[col]

          hash[col] = hash[col].to_json
        end
        hash
      end

      def deserialize_collection(array_of_hashes, json_columns)
        array_of_hashes.map do |hash|
          deserialize_json_columns(hash, json_columns)
        end
      end

      def deserialize_json_columns(hash, json_columns)
        hash = hash.clone # do not mutate parameter
        json_columns.each do |col|
          next unless hash[col]

          hash[col] = JSON.parse(hash[col])
        end
        hash
      end
    end
  end
end
