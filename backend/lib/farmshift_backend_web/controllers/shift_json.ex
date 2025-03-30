defmodule FarmshiftBackendWeb.ShiftJSON do
  alias FarmshiftBackend.Shifts.Shift
  alias FarmshiftBackendWeb.EmployeeJSON

  def index(%{shifts: shifts}) do
    %{data: for(shift <- shifts, do: data(shift))}
  end

  def show(%{shift: shift}) do
    %{data: data(shift)}
  end

  defp data(%Shift{} = shift) do
    %{
      id: shift.id,
      day: shift.day,
      time_slot: shift.time_slot,
      notes: shift.notes,
      is_confirmed: shift.is_confirmed,
      employee: shift.employee && EmployeeJSON.data(shift.employee)
    }
  end
end
