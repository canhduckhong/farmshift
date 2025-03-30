defmodule FarmshiftBackend.Repo.Migrations.CreateShifts do
  use Ecto.Migration

  def change do
    create table(:shifts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :day, :string, null: false
      add :time_slot, :string, null: false
      add :notes, :text
      add :is_confirmed, :boolean, default: false, null: false
      add :employee_id, references(:employees, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:shifts, [:employee_id])
    create unique_index(:shifts, [:day, :time_slot, :employee_id], name: :unique_shift_per_employee)
  end
end
