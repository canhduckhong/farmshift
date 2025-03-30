defmodule FarmshiftBackend.Shifts do
  @moduledoc """
  Context for managing shifts.
  Provides CRUD operations for shift records.
  """

  import Ecto.Query, warn: false
  alias FarmshiftBackend.Repo

  alias FarmshiftBackend.Shifts.Shift
  alias FarmshiftBackend.Employees

  @doc """
  Returns the list of shifts with optional filtering.

  ## Examples

      iex> list_shifts(%{day: "Monday"})
      [%Shift{}, ...]

      iex> list_shifts(%{employee_id: "some-uuid"})
      [%Shift{}, ...]

  """
  def list_shifts(params \\ %{}) do
    Shift
    |> filter_shifts(params)
    |> Repo.all()
    |> Repo.preload(:employee)
  end

  defp filter_shifts(query, params) do
    Enum.reduce(params, query, fn
      {:day, day}, q -> where(q, [s], s.day == ^day)
      {:time_slot, time_slot}, q -> where(q, [s], s.time_slot == ^time_slot)
      {:employee_id, employee_id}, q -> where(q, [s], s.employee_id == ^employee_id)
      {:is_confirmed, is_confirmed}, q -> where(q, [s], s.is_confirmed == ^is_confirmed)
      _, q -> q
    end)
  end

  @doc """
  Gets a single shift.

  Raises `Ecto.NoResultsError` if the Shift does not exist.

  ## Examples

      iex> get_shift!("uuid-here")
      %Shift{}

      iex> get_shift!("non-existent-uuid")
      ** (Ecto.NoResultsError)

  """
  def get_shift!(id) do
    Shift
    |> Repo.get!(id)
    |> Repo.preload(:employee)
  end

  @doc """
  Creates a shift.

  ## Examples

      iex> create_shift(%{day: "Monday", time_slot: "Morning", employee_id: "employee-uuid"})
      {:ok, %Shift{}}

      iex> create_shift(%{day: ""})
      {:error, %Ecto.Changeset{}}

  """
  def create_shift(attrs \\ %{}) do
    %Shift{}
    |> Shift.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a shift.

  ## Examples

      iex> update_shift(shift, %{notes: "Updated notes"})
      {:ok, %Shift{}}

      iex> update_shift(shift, %{day: ""})
      {:error, %Ecto.Changeset{}}

  """
  def update_shift(%Shift{} = shift, attrs) do
    shift
    |> Shift.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a shift.

  ## Examples

      iex> delete_shift(shift)
      {:ok, %Shift{}}

      iex> delete_shift(shift)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shift(%Shift{} = shift) do
    Repo.delete(shift)
  end

  @doc """
  Assigns a shift to an employee.

  ## Examples

      iex> assign_shift("employee-uuid", "Monday", "Morning")
      {:ok, %Shift{}}

  """
  def assign_shift(employee_id, day, time_slot, notes \\ nil) do
    # First, check if the employee exists
    _employee = Employees.get_employee!(employee_id)

    attrs = %{
      employee_id: employee_id,
      day: day,
      time_slot: time_slot,
      notes: notes,
      is_confirmed: true
    }

    case create_shift(attrs) do
      {:ok, shift} -> 
        {:ok, Repo.preload(shift, :employee)}
      error -> error
    end
  end

  @doc """
  Unassigns a shift by removing the employee association.

  ## Examples

      iex> unassign_shift(shift)
      {:ok, %Shift{}}

  """
  def unassign_shift(%Shift{} = shift) do
    update_shift(shift, %{employee_id: nil, is_confirmed: false})
  end
end
