defmodule FarmshiftBackend.Repo.Migrations.CreateEmployees do
  use Ecto.Migration

  def change do
    # Ensure UUID extension is available
    execute "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"", 
            "DROP EXTENSION IF EXISTS \"uuid-ossp\""

    # Create employees table with UUID primary key
    create table(:employees, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :name, :string, null: false
      add :role, :string, null: false
      add :employment_type, :string, null: false
      add :skills, {:array, :string}
      add :preferences, :map
      add :max_shifts_per_week, :integer, default: 5

      timestamps(type: :utc_datetime)
    end

    # Create index on name for faster lookups
    create index(:employees, [:name])
  end

  def down do
    drop table(:employees)
  end
end
