module Persistence::Users
  extend GenericCrud
  with(table: :users, array_column: :roles)
end
