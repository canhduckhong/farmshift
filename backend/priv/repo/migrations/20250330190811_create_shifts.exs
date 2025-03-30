defmodule FarmshiftBackend.Repo.Migrations.CreateShifts do
  use Ecto.Migration

  def change do
    create table(:shifts) do
      add :day, :string, null: false
      add :time_slot, :string, null: false
      add :employee_id, references(:employees, on_delete: :nilify_all)
      add :notes, :text
      add :is_confirmed, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:shifts, [:day, :time_slot, :employee_id], 
      name: :unique_shift_per_employee_per_day_time_slot
    )
  end
end
