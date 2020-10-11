# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:job_posts) do
      primary_key :id
      String :company_name, null: false
      String :rich_description, null: false
      TrueClass :active, default: true
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP, index: true
      DateTime :posted_on
    end
  end
end
