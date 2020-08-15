Sequel.migration do
  change do
    create_table(:schema_migrations) do
      column :filename, "text", :null=>false
      
      primary_key [:filename]
    end
    
    create_table(:users) do
      primary_key :id
      column :name, "text", :null=>false
      column :email, "text", :null=>false
      
      index [:email], :name=>:users_email_key, :unique=>true
    end
  end
end
