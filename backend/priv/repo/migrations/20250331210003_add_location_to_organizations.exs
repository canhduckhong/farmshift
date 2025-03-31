defmodule FarmshiftBackend.Repo.Migrations.AddLocationToOrganizations do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      # Add columns only if they don't already exist
      if !column_exists?(:organizations, :country), do: add(:country, :string)
      if !column_exists?(:organizations, :locale), do: add(:locale, :string)
      if !column_exists?(:organizations, :timezone), do: add(:timezone, :string)
      if !column_exists?(:organizations, :description), do: add(:description, :string)
    end
  end

  # Helper function to check if a column exists
  defp column_exists?(table, column) do
    Ecto.Adapters.SQL.query!(
      FarmshiftBackend.Repo,
      "SELECT column_name FROM information_schema.columns WHERE table_name = $1 AND column_name = $2",
      [to_string(table), to_string(column)]
    ).rows != []
  end
end
