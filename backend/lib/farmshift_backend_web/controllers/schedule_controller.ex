defmodule FarmshiftBackendWeb.ScheduleController do
  use FarmshiftBackendWeb, :controller

  alias FarmshiftBackend.Scheduling
  alias FarmshiftBackend.Employees

  @doc """
  Generate an optimal schedule for a specific week.

  Expects a JSON payload with:
  - week_number: Integer representing the week to schedule
  - config: AI scheduling configuration
  """
  def generate_schedule(conn, %{
    "week_number" => week_number,
    "config" => config
  }) do
    # Validate input data
    with {:ok, validated_config} <- validate_config(config),
         {:ok, employees} <- fetch_available_employees(),
         {:ok, initial_shifts} <- generate_initial_shifts(week_number) do
      
      # Generate optimal schedule
      case Scheduling.generate_optimal_schedule(
        initial_shifts, 
        employees, 
        validated_config
      ) do
        {:ok, schedule} ->
          # Respond with generated schedule
          conn
          |> put_status(:ok)
          |> json(%{
            schedule: schedule,
            week_number: week_number,
            message: "Schedule generated successfully"
          })
        {:error, reason} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: reason})
      end
    else
      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end

  # Fetch all active employees
  defp fetch_available_employees do
    case Employees.list_active_employees() do
      [] -> {:error, "No available employees"}
      employees -> {:ok, employees}
    end
  end

  # Generate initial shifts for the given week
  defp generate_initial_shifts(week_number) do
    # Define days of the week
    days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    time_slots = ["Morning", "Afternoon", "Evening"]

    # Generate shifts for each day and time slot
    shifts = for day <- days, time_slot <- time_slots do
      %{
        id: "#{day}-#{time_slot}-Week#{week_number}",
        day: day,
        time_slot: time_slot,
        week_number: week_number,
        employee_id: nil,
        role: nil
      }
    end

    {:ok, shifts}
  end

  # Validate AI configuration
  defp validate_config(config) do
    # Basic validation for AI configuration
    cond do
      is_nil(config) -> {:error, "Configuration cannot be nil"}
      not is_map(config) -> {:error, "Invalid configuration format"}
      not Map.has_key?(config, "enabled_rules") -> {:error, "Missing enabled rules"}
      not is_list(config["enabled_rules"]) -> {:error, "Enabled rules must be a list"}
      Enum.any?(config["enabled_rules"], fn rule -> not is_map(rule) end) -> {:error, "Enabled rules must be a list of maps"}
      true -> {:ok, config}
    end
  end
end
