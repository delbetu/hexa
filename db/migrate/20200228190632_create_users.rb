# frozen_string_literal: true

Sequel.migration do
  up do
    create_table :users do
      primary_key :id
      String :name, null: false
      String :email, null: false, unique: true
      String :password, null: false
      String :roles, null: false
    end
    alter_table (:users) { set_column_default :roles, "[]" }
  end

  down do
    drop_table :users
  end
end
