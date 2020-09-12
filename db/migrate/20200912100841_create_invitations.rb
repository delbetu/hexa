Sequel.migration do
  up do
    create_table :invitations do
      primary_key :id
      String :uuid, null: false, index: true
      String :status, null: false
      String :email, null: false, unique: true
      String :roles, null: false
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP, index: true
    end
    alter_table (:invitations) { set_column_default :roles, "[]" }
  end

  down do
    drop_table :invitations
  end
end
