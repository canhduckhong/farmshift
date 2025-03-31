defmodule FarmshiftBackend.Repo.Migrations.AddPlanToOrganizations do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add :plan, :string, default: "free"
    end

    alter table(:users) do
      add :language, :string
    end
  end
end
