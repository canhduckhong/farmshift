defmodule FarmshiftBackend.Shifts do
  @moduledoc """
  Context for managing employee shifts
  """
  import Ecto.Query
  alias FarmshiftBackend.Repo
  alias FarmshiftBackend.Shifts.Shift

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
      _, q -> q
    end)
  end

  def get_shift!(id), do: Repo.get!(Shift, id) |> Repo.preload(:employee)

  def create_shift(attrs \\ %{}) do
    %Shift{}
    |> Shift.changeset(attrs)
    |> Repo.insert()
  end

  def update_shift(%Shift{} = shift, attrs) do
    shift
    |> Shift.changeset(attrs)
    |> Repo.update()
  end

  def delete_shift(%Shift{} = shift), do: Repo.delete(shift)

  def assign_shift(employee_id, day, time_slot, notes \\ nil) do
    attrs = %{
      employee_id: employee_id,
      day: day,
      time_slot: time_slot,
      notes: notes,
      is_confirmed: true
    }

    %Shift{}
    |> Shift.changeset(attrs)
    |> Repo.insert(
      on_conflict: [set: [employee_id: employee_id, notes: notes, is_confirmed: true]],
      conflict_target: [:day, :time_slot]
    )
  end

  def unassign_shift(day, time_slot) do
    from(s in Shift, where: s.day == ^day and s.time_slot == ^time_slot)
    |> Repo.update_all(set: [employee_id: nil, is_confirmed: false, notes: nil])
  end
end
