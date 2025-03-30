defmodule FarmshiftBackend.Employees.Employee do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "employees" do
    field :name, :string
    field :role, :string
    field :employment_type, :string
    field :skills, {:array, :string}
    field :preferences, :map
    field :max_shifts_per_week, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(employee, attrs) do
    employee
    |> cast(attrs, [:name, :role, :employment_type, :skills, :preferences, :max_shifts_per_week])
    |> validate_required([:name, :role, :employment_type])
    |> validate_inclusion(:employment_type, ["fulltime", "parttime", "seasonal"])
    |> validate_number(:max_shifts_per_week, greater_than: 0, less_than_or_equal_to: 7)
  end

  @doc """
  Converts the employee struct to a map for API response
  """
  def to_response(employee) do
    %{
      id: employee.id,
      name: employee.name,
      role: employee.role,
      employmentType: employee.employment_type,
      skills: employee.skills,
      preferences: employee.preferences,
      maxShiftsPerWeek: employee.max_shifts_per_week
    }
  end
end
