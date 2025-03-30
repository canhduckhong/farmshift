defmodule FarmshiftBackend.Repo.Migrations.AddUuidSupport do
  use Ecto.Migration

  def change do
    # Ensure UUID extension is available
    execute "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"", 
            "DROP EXTENSION IF EXISTS \"uuid-ossp\""

    # Drop existing users table
    drop table(:users)

    # Create new users table with UUID primary key
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :name, :string
      add :role, :string, default: "employee"

      timestamps(type: :utc_datetime)
    end

    # Create unique index on email
    create unique_index(:users, [:email])
  end

  def down do
    # Revert to the previous integer-based users table
    drop table(:users)

    create table(:users) do
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :name, :string
      add :role, :string, default: "employee"

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
  end
end
