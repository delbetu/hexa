module Ports
  module Crud
    def with(table:, json_columns: []); end
    def create(attributes); end
    def read(options = {}); end
    def update(attributes); end
    def delete(id:); end
  end
end
