Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :email,              null: false
      String :encrypted_password, null: false
    end
  end
end
