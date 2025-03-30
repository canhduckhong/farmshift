defmodule FarmshiftBackendWeb.ShiftController do
  use FarmshiftBackendWeb, :controller

  alias FarmshiftBackend.Shifts
  alias FarmshiftBackend.Shifts.Shift

  action_fallback FarmshiftBackendWeb.FallbackController

  def index(conn, params) do
    shifts = Shifts.list_shifts(params)
    render(conn, :index, shifts: shifts)
  end

  def create(conn, %{"shift" => shift_params}) do
    with {:ok, %Shift{} = shift} <- Shifts.create_shift(shift_params) do
      conn
      |> put_status(:created)
      |> render(:show, shift: shift)
    end
  end

  def show(conn, %{"id" => id}) do
    shift = Shifts.get_shift!(id)
    render(conn, :show, shift: shift)
  end

  def update(conn, %{"id" => id, "shift" => shift_params}) do
    shift = Shifts.get_shift!(id)

    with {:ok, %Shift{} = shift} <- Shifts.update_shift(shift, shift_params) do
      render(conn, :show, shift: shift)
    end
  end

  def delete(conn, %{"id" => id}) do
    shift = Shifts.get_shift!(id)

    with {:ok, %Shift{}} <- Shifts.delete_shift(shift) do
      send_resp(conn, :no_content, "")
    end
  end

  def assign(conn, %{"employee_id" => employee_id, "day" => day, "time_slot" => time_slot, "notes" => notes}) do
    with {:ok, %Shift{} = shift} <- Shifts.assign_shift(employee_id, day, time_slot, notes) do
      conn
      |> put_status(:created)
      |> render(:show, shift: shift)
    end
  end

  def unassign(conn, %{"day" => day, "time_slot" => time_slot}) do
    {count, _} = Shifts.unassign_shift(day, time_slot)
    send_resp(conn, :ok, "#{count} shifts unassigned")
  end
end
