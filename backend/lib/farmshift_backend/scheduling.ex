defmodule FarmshiftBackend.Scheduling do
  @moduledoc """
  Provides AI-powered scheduling functionality for generating optimal employee shifts.
  """

  @shift_requirements %{
    "Morning" => ["Milking", "Feeding"],
    "Afternoon" => ["Cleaning", "Maintenance"],
    "Evening" => ["Milking", "Security"]
  }

  @doc """
  Generate an optimal schedule based on employee qualifications, preferences, and rules.
  """
  def generate_optimal_schedule(initial_shifts, employees, config) do
    # Create a copy of initial shifts to work with
    schedule = Enum.map(initial_shifts, fn shift -> 
      Map.merge(shift, %{employee_id: nil, role: nil}) 
    end)

    # Get enabled validation rules
    enabled_rules = Enum.filter(config["enabled_rules"], fn rule -> rule["enabled"] end)

    # Sort shifts by priority (e.g., Morning, Evening, Afternoon)
    sorted_shifts = Enum.sort_by(schedule, fn shift -> 
      case shift["time_slot"] do
        "Morning" -> 0
        "Evening" -> 1
        "Afternoon" -> 2
        _ -> 3
      end
    end)

    # Assign employees to shifts
    Enum.reduce(sorted_shifts, schedule, fn shift, acc ->
      # Find eligible employees for this shift
      eligible_employees = Enum.filter(employees, fn employee ->
        can_assign_employee_to_shift?(
          employee, 
          shift["day"], 
          shift["time_slot"], 
          acc, 
          enabled_rules
        )
      end)

      # If eligible employees exist, find the best match
      case eligible_employees do
        [] -> 
          # No eligible employee found, keep the shift unassigned
          acc

        _ -> 
          # Score and find the best employee
          best_match = Enum.max_by(eligible_employees, fn employee ->
            score_assignment(
              employee, 
              shift["day"], 
              shift["time_slot"], 
              config
            )
          end)

          # Update the schedule with the best employee
          updated_shift = Map.merge(shift, %{
            "employee_id" => best_match["id"],
            "role" => find_matching_role(best_match, shift["time_slot"])
          })

          # Replace the old shift with the updated one
          List.replace_at(acc, Enum.find_index(acc, fn s -> s["id"] == shift["id"] end), updated_shift)
      end
    end)
  end

  @doc """
  Check if an employee can be assigned to a shift based on validation rules.
  """
  def can_assign_employee_to_shift?(employee, day, time_slot, current_schedule, rules) do
    Enum.all?(rules, fn rule ->
      case rule["name"] do
        "skillMatch" -> 
          has_required_skills?(employee, time_slot)

        "noConsecutiveShifts" -> 
          !has_shift_on_day?(employee, day, current_schedule)

        "maxShiftsPerWeek" -> 
          shifts_count_this_week(employee, current_schedule) < employee["max_shifts_per_week"]

        "respectDaysOff" -> 
          !is_preferred_day_off?(employee, day)

        "maxConsecutiveDays" -> 
          !exceeds_max_consecutive_days?(employee, day, current_schedule)

        _ -> 
          true
      end
    end)
  end

  @doc """
  Score a potential assignment based on preferences and other factors.
  """
  def score_assignment(employee, day, time_slot, config) do
    base_score = 10

    skill_match_score = 
      if config["prioritize_skill_match"] && has_required_skills?(employee, time_slot) do
        30
      else
        0
      end

    preferred_shift_score = 
      if config["respect_preferences"] && is_preferred_shift?(employee, time_slot) do
        20
      else
        0
      end

    preferred_day_penalty = 
      if config["respect_preferences"] && is_preferred_day_off?(employee, day) do
        -15
      else
        0
      end

    employment_type_score = 
      case employee["employment_type"] do
        "fulltime" -> 5
        _ -> 0
      end

    skill_bonus = 
      count_matching_skills(employee, time_slot) * 3

    base_score + skill_match_score + preferred_shift_score + 
    preferred_day_penalty + employment_type_score + skill_bonus
  end

  # Helper functions

  defp has_required_skills?(employee, time_slot) do
    required_skills = Map.get(@shift_requirements, time_slot, [])
    Enum.any?(required_skills, fn skill -> skill in employee["skills"] end)
  end

  defp find_matching_role(employee, time_slot) do
    required_skills = Map.get(@shift_requirements, time_slot, [])
    Enum.find(employee["skills"], fn skill -> skill in required_skills end)
  end

  defp has_shift_on_day?(employee, day, current_schedule) do
    Enum.any?(current_schedule, fn shift -> 
      shift["employee_id"] == employee["id"] && shift["day"] == day 
    end)
  end

  defp shifts_count_this_week(employee, current_schedule) do
    Enum.count(current_schedule, fn shift -> 
      shift["employee_id"] == employee["id"] 
    end)
  end

  defp is_preferred_day_off?(employee, day) do
    day in employee["preferences"]["preferred_days_off"]
  end

  defp is_preferred_shift?(employee, time_slot) do
    time_slot in employee["preferences"]["preferred_shifts"]
  end

  defp count_matching_skills(employee, time_slot) do
    required_skills = Map.get(@shift_requirements, time_slot, [])
    Enum.count(required_skills, fn skill -> skill in employee["skills"] end)
  end

  defp exceeds_max_consecutive_days?(employee, day, current_schedule) do
    days_of_week = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    day_index = Enum.find_index(days_of_week, fn d -> d == day end)

    consecutive_days = 
      Enum.reduce_while(1..6, 1, fn i, acc -> 
        prev_day_index = rem(day_index - i + 7, 7)
        prev_day = Enum.at(days_of_week, prev_day_index)

        if has_shift_on_day?(employee, prev_day, current_schedule) do
          {:cont, acc + 1}
        else
          {:halt, acc}
        end
      end)

    consecutive_days > 6
  end
end
