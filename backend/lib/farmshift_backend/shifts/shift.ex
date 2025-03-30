defmodule FarmshiftBackend.Shifts.Shift do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shifts" do
    field :day, :string
    field :time_slot, :string
    field :notes, :string
    field :is_confirmed, :boolean, default: false

    belongs_to :employee, FarmshiftBackend.Employees.Employee

    timestamps()
  end

  @doc false
  def changeset(shift, attrs) do
    shift
    |> cast(attrs, [:day, :time_slot, :employee_id, :notes, :is_confirmed])
    |> validate_required([:day, :time_slot])
    |> validate_inclusion(:day, ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"])
    |> validate_inclusion(:time_slot, ["Morning", "Afternoon", "Evening"])
    |> foreign_key_constraint(:employee_id)
    |> unique_constraint([:day, :time_slot, :employee_id], 
      name: :unique_shift_per_employee_per_day_time_slot,
      message: "Employee cannot have multiple shifts in the same day and time slot"
    )
  end
end
