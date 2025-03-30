defmodule FarmshiftBackend.Shifts.Shift do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "shifts" do
    field :day, :string
    field :time_slot, :string
    field :notes, :string
    field :is_confirmed, :boolean, default: false

    belongs_to :employee, FarmshiftBackend.Employees.Employee, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shift, attrs) do
    shift
    |> cast(attrs, [:day, :time_slot, :notes, :is_confirmed, :employee_id])
    |> validate_required([:day, :time_slot])
    |> validate_inclusion(:day, ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"])
    |> validate_inclusion(:time_slot, ["Morning", "Afternoon", "Evening"])
    |> foreign_key_constraint(:employee_id)
  end

  @doc """
  Converts the shift struct to a map for API response
  """
  def to_response(shift) do
    %{
      id: shift.id,
      day: shift.day,
      time_slot: shift.time_slot,
      notes: shift.notes,
      is_confirmed: shift.is_confirmed,
      employee_id: shift.employee_id
    }
  end
end
