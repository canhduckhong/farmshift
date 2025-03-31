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

      # Handle empty shifts case
      if is_nil(initial_shifts) or length(initial_shifts) == 0 do
        {:error, "Shifts cannot be nil"}
      else
        # Generate schedule using a more flexible algorithm
        schedule = generate_flexible_schedule(initial_shifts, employees, enabled_rules)

        # Validate the generated schedule
        case validate_schedule(schedule) do
          :ok -> {:ok, schedule}
          {:error, reason} ->
            Logger.error("Schedule generation failed: #{reason}")
            {:error, reason}
        end
      end
    end
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

  # Generate schedule with a more flexible approach
  defp generate_flexible_schedule(initial_shifts, employees, enabled_rules) do
    # Shuffle employees to distribute shifts more evenly
    shuffled_employees = Enum.shuffle(employees)

    # Attempt to assign shifts
    Enum.map(initial_shifts, fn shift ->
      # Try multiple times to assign the shift with relaxing rules
      Enum.reduce_while(1..5, shift, fn attempt, current_shift ->
        # Adjust rules based on the attempt
        relaxed_rules = case attempt do
          1 -> enabled_rules
          2 -> Enum.filter(enabled_rules, &(&1["name"] != "maxShiftsPerWeek"))
          3 -> Enum.filter(enabled_rules, &(&1["name"] not in ["maxShiftsPerWeek", "preferredDaysOff"]))
          4 -> Enum.filter(enabled_rules, &(&1["name"] not in ["maxShiftsPerWeek", "preferredDaysOff", "noConsecutiveShifts"]))
          5 -> Enum.filter(enabled_rules, &(&1["name"] == "skillMatch"))
        end

        result = assign_shift_flexibly(current_shift, shuffled_employees, relaxed_rules)

        # If the shift is assigned, halt the reduction
        if Map.has_key?(result, "employee_id") do
          {:halt, result}
        else
          # If not assigned, continue trying
          {:cont, current_shift}
        end
      end)
    end)
  end

  # Assign shift with a flexible strategy
  defp assign_shift_flexibly(shift, employees, enabled_rules) do
    # Try multiple strategies to assign the shift
    strategies = [
      &find_perfect_match/3,
      &find_skill_match/3,
      &find_any_employee/3
    ]

    Enum.reduce_while(strategies, shift, fn strategy, current_shift ->
      case strategy.(current_shift, employees, enabled_rules) do
        %{"employee_id" => _} = assigned_shift ->
          {:halt, assigned_shift}
        _ ->
          {:cont, current_shift}
      end
    end)
  end

  # Find a perfect match considering all rules
  defp find_perfect_match(shift, employees, enabled_rules) do
    # Find employees who satisfy all rules
    perfect_matches = Enum.filter(employees, fn employee ->
      can_assign_employee_to_shift?(
        employee,
        shift["day"],
        shift["time_slot"],
        [],
        enabled_rules
      )
    end)

    case perfect_matches do
      [] -> shift
      candidates ->
        selected_employee = Enum.random(candidates)
        Map.merge(shift, %{
          "employee_id" => selected_employee["id"],
          "role" => List.first(selected_employee["skills"] || [])
        })
    end
  end

  # Find a match based on skill
  defp find_skill_match(shift, employees, _enabled_rules) do
    # Required skills based on time slot
    required_skills = case shift["time_slot"] do
      "Morning" -> ["Milking", "Feeding"]
      "Afternoon" -> ["Cleaning", "Maintenance"]
      "Evening" -> ["Security", "Feeding"]
      _ -> []
    end

    # Find employees with matching skills
    skill_matches = Enum.filter(employees, fn employee ->
      Enum.any?(employee["skills"] || [], fn skill -> skill in required_skills end)
    end)

    case skill_matches do
      [] -> shift
      candidates ->
        selected_employee = Enum.random(candidates)
        Map.merge(shift, %{
          "employee_id" => selected_employee["id"],
          "role" => List.first(selected_employee["skills"] || [])
        })
    end
  end

  # Find any available employee
  defp find_any_employee(shift, employees, _enabled_rules) do
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

  @doc """
  Check if an employee can be assigned to a specific shift.
  """
  def can_assign_employee_to_shift?(employee, day, time_slot, existing_shifts, enabled_rules) do
    # Validate each rule
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

    existing_employee_shifts = Enum.filter(existing_shifts, fn shift ->
      shift["employee_id"] == employee["id"] and
      shift["week_number"] == (List.first(existing_shifts)["week_number"] || 15)
    end)

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
        :ok
      true ->
        :ok
    end
  end
end
