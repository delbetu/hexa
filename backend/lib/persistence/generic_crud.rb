require 'shared/ports'

module GenericCrud
  extend ::Ports::Crud

  # TODO: don't default to nil
  def with(table:, array_column: nil)
    @table = table.freeze
    @array_column = array_column.freeze
  end

  def entity_name
    @table.to_s.singularize.capitalize
  end

  def create(attributes)
    attributes = attributes.transform_keys(&:to_sym)
    fix_array_column(attributes)
    id = DB[@table].insert(attributes)
    attributes.merge!(id: id)
    attributes
  rescue Sequel::DatabaseError => e
    # TODO: Inject a logger in persistence and Log message and stacktrace
    raise Persistence::CreateError, "Error creating #{entity_name} with #{attributes}"
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
            Sequel.desc(attr.to_sym)
          else
            Sequel.asc(attr.to_sym)
          end

        result = result.order(order)
      end
    end

    # TODO: Include total number on result and the fetched number
    # so we can do: showing 10 of 1892
    result.all
  end

  # returns only the affected attributes
  def update(attributes)
    id = attributes.delete(:id)
    raise Persistence::UpdateError, "id is required for update" unless id

    affected_rows = DB[@table].where(id: id).update(attributes)
    raise Persistence::UpdateError, "#{entity_name} with id: #{id} not found" if affected_rows == 0

    attributes.merge!(id: id)
    attributes
  rescue Sequel::DatabaseError => e
    # TODO: Inject a logger in persistence and Log message and stacktrace
    raise Persistence::UpdateError, "Error updating #{entity_name} with #{attributes}"
  end

  def delete(id:)
    row_to_delete = DB[@table].where(id: id).first
    affected_rows = DB[@table].where(id: id).delete
    raise Persistence::DeleteError, "#{entity_name} with id: #{id} not found" if affected_rows == 0

    row_to_delete
  rescue Sequel::DatabaseError => e
    # TODO: Inject a logger in persistence and Log message and stacktrace
    raise Persistence::DeleteError, "Error deleting #{entity_name} with #{attributes}"
  end

  private

  def fix_array_column(attributes)
    return unless @array_column
    # when generic crud is used with option array_column
    # it standarizes the input as pg_array as required
    attributes[@array_column.to_sym] = attributes[@array_column]&.pg_array || [] if @array_column
  end
end
