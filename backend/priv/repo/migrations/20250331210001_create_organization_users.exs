defmodule FarmshiftBackend.Repo.Migrations.CreateOrganizationUsers do
  use Ecto.Migration

  def change do
    create table(:organization_users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :organization_id, references(:organizations, type: :binary_id, on_delete: :delete_all)
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)
      add :role, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:organization_users, [:organization_id, :user_id], name: :org_user_unique_index)
    create index(:organization_users, [:organization_id])
    create index(:organization_users, [:user_id])
  end
end
