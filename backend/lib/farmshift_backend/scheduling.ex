defmodule FarmshiftBackend.Scheduling do
  @moduledoc """
  Handles optimal schedule generation for employees.
  """

  require Logger

  @doc """
  Generate an optimal schedule based on given shifts, employees, and configuration.
  """
  def generate_optimal_schedule(initial_shifts, employees, config) do
    # Validate inputs
    with :ok <- validate_inputs(initial_shifts, employees, config) do
      # Prepare configuration rules
      enabled_rules = config["enabled_rules"] || []

      # Attempt to assign shifts with multiple passes
      schedule = assign_shifts_with_multiple_passes(initial_shifts, employees, enabled_rules)

      # Validate the generated schedule
      case validate_schedule(schedule) do
        :ok -> {:ok, schedule}
        {:error, reason} -> 
          Logger.error("Schedule generation failed: #{reason}")
          {:error, reason}
      end
    end
  end

  @doc """
  Check if an employee can be assigned to a specific shift.
  """
  def can_assign_employee_to_shift?(employee, day, time_slot, existing_shifts, enabled_rules) do
    # Check each rule
    Enum.all?(enabled_rules, fn rule ->
      case rule["name"] do
        "skillMatch" -> check_skill_match(employee, time_slot)
        "noConsecutiveShifts" -> check_no_consecutive_shifts(employee, day, existing_shifts)
        "maxShiftsPerWeek" -> check_max_shifts_per_week(employee, existing_shifts)
        "preferredDaysOff" -> check_preferred_days_off(employee, day)
        _ -> true
      end
    end)
  end

  # Validate input parameters
  defp validate_inputs(initial_shifts, employees, config) do
    cond do
      is_nil(initial_shifts) -> {:error, "Shifts cannot be nil"}
      is_nil(employees) or length(employees) == 0 -> {:error, "No employees available"}
      is_nil(config) -> {:error, "Configuration cannot be nil"}
      true -> :ok
    end
  end

  # Multiple pass shift assignment strategy
  defp assign_shifts_with_multiple_passes(initial_shifts, employees, enabled_rules) do
    # First pass: Prioritize skill matching and preferences
    schedule = Enum.map(initial_shifts, fn shift ->
      assign_shift_to_best_employee(shift, employees, enabled_rules)
    end)

    # Second pass: Fill remaining unassigned shifts with more relaxed rules
    schedule
    |> Enum.map(fn shift ->
      if shift["employee_id"] == nil do
        assign_shift_to_best_employee_relaxed(shift, employees, enabled_rules)
      else
        shift
      end
    end)
    # Third pass: Assign any remaining shifts to any available employee
    |> Enum.map(fn shift ->
      if shift["employee_id"] == nil do
        assign_shift_to_any_employee(shift, employees)
      else
        shift
      end
    end)
  end

  # Find the best employee for a specific shift with strict rules
  defp assign_shift_to_best_employee(shift, employees, enabled_rules) do
    # Find eligible employees
    eligible_employees = Enum.filter(employees, fn employee ->
      can_assign_employee_to_shift?(
        employee, 
        shift["day"], 
        shift["time_slot"], 
        [], 
        enabled_rules
      )
    end)

    # Select an employee if available
    case eligible_employees do
      [] -> shift
      candidates -> 
        selected_employee = Enum.random(candidates)
        Map.merge(shift, %{
          "employee_id" => selected_employee["id"],
          "role" => List.first(selected_employee["skills"] || [])
        })
    end
  end

  # Find the best employee for a specific shift with relaxed rules
  defp assign_shift_to_best_employee_relaxed(shift, employees, enabled_rules) do
    # Relaxed rules: only check skill match
    relaxed_rules = Enum.filter(enabled_rules, & &1["name"] == "skillMatch")

    # Find eligible employees
    eligible_employees = Enum.filter(employees, fn employee ->
      can_assign_employee_to_shift?(
        employee, 
        shift["day"], 
        shift["time_slot"], 
        [], 
        relaxed_rules
      )
    end)

    # Select an employee if available
    case eligible_employees do
      [] -> shift
      candidates -> 
        selected_employee = Enum.random(candidates)
        Map.merge(shift, %{
          "employee_id" => selected_employee["id"],
          "role" => List.first(selected_employee["skills"] || [])
        })
    end
  end

  # Assign shift to any available employee
  defp assign_shift_to_any_employee(shift, employees) do
    case employees do
      [] -> shift
      candidates -> 
        selected_employee = Enum.random(candidates)
        Map.merge(shift, %{
          "employee_id" => selected_employee["id"],
          "role" => List.first(selected_employee["skills"] || [])
        })
    end
  end

  # Skill matching validation
  defp check_skill_match(employee, time_slot) do
    required_skills = case time_slot do
      "Morning" -> ["Milking", "Feeding"]
      "Afternoon" -> ["Cleaning", "Maintenance"]
      "Evening" -> ["Security", "Feeding"]
      _ -> []
    end

    Enum.any?(employee["skills"] || [], fn skill -> skill in required_skills end)
  end

  # Prevent consecutive shifts
  defp check_no_consecutive_shifts(employee, day, existing_shifts) do
    existing_shifts_for_employee = Enum.filter(existing_shifts, 
      &(&1["employee_id"] == employee["id"])
    )
    
    !Enum.any?(existing_shifts_for_employee, &(&1["day"] == day))
  end

  # Limit maximum shifts per week
  defp check_max_shifts_per_week(employee, existing_shifts) do
    max_shifts = employee["max_shifts_per_week"] || 5
    existing_employee_shifts = Enum.filter(existing_shifts, 
      &(&1["employee_id"] == employee["id"])
    )
    
    length(existing_employee_shifts) < max_shifts
  end

  # Respect preferred days off
  defp check_preferred_days_off(employee, day) do
    preferred_days_off = employee["preferences"]["preferred_days_off"] || []
    day not in preferred_days_off
  end

  # Validate the final schedule
  defp validate_schedule(schedule) do
    unassigned_shifts = Enum.filter(schedule, & &1["employee_id"] == nil)
    
    cond do
      length(unassigned_shifts) > 0 -> 
        Logger.warning("Unable to assign employees to #{length(unassigned_shifts)} shifts")
        {:error, "Unable to assign employees to #{length(unassigned_shifts)} shifts"}
      true -> 
        :ok
    end
  end
end
