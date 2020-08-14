# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :users do
      primary_key :id
      String :name, null: false
      String :email, null: false, unique: true
      String :password, null: false
      String :roles, null: false
    end
    alter_table (:users) { set_column_default :roles, "[]" }
  end
end
