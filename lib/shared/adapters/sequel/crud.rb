require 'shared/ports'
require 'shared/errors'

module Adapters
  module Sequel
    module Crud
      extend ::Ports::Crud

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
        attributes.merge!(id: id)
        attributes
      rescue ::Sequel::DatabaseError => e
        Raven.capture_exception(e)
        raise CreateError, "Error creating #{entity_name} with #{attributes}"
      end

      def read(options = {})
        result = DB[@table]

        if !!options[:filters]
          # TODO: implement failing spec
          # filter by or
          options[:filters].each do |filter|
            result = result.where(filter)
          end
        end

        if !!options[:pagination]
          page = options.dig(:pagination, :page) || 1
          per_page = options.dig(:pagination, :per_page) || 10
          offset = (page - 1) * per_page
          result = result.limit(per_page).offset(offset)
        end

        if !!options[:sort]
          sort_attributes = options.dig(:sort)

          sort_attributes.each do |sort_option|
            attr, direction = sort_option[:attr], sort_option[:direction]
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
        raise UpdateError, "id is required for update" unless id
        attributes = serialize_json_columns(attributes, @json_columns)

        affected_rows = DB[@table].where(id: id).update(attributes)
        raise UpdateError, "#{entity_name} with id: #{id} not found" if affected_rows == 0

        attributes.merge!(id: id)
        attributes
      rescue ::Sequel::DatabaseError => e
        # TODO: Inject a logger in persistence and Log message and stacktrace
        raise UpdateError, "Error updating #{entity_name} with #{attributes}"
      end

      def delete(id:)
        row_to_delete = DB[@table].where(id: id).first
        affected_rows = DB[@table].where(id: id).delete
        raise DeleteError, "#{entity_name} with id: #{id} not found" if affected_rows == 0

        row_to_delete
      rescue ::Sequel::DatabaseError => e
        # TODO: Inject a logger in persistence and Log message and stacktrace
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
