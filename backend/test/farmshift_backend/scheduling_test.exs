defmodule FarmshiftBackend.SchedulingTest do
  use ExUnit.Case, async: true

  alias FarmshiftBackend.Scheduling

  setup do
    # Sample employees with different skills and preferences
    employees = [
      %{
        id: "emp1",
        name: "John Doe",
        skills: ["Milking", "Feeding"],
        employment_type: "fulltime",
        max_shifts_per_week: 5,
        preferences: %{
          preferred_days_off: ["Sunday"],
          preferred_shifts: ["Morning"]
        }
      },
      %{
        id: "emp2",
        name: "Jane Smith",
        skills: ["Cleaning", "Maintenance"],
        employment_type: "parttime",
        max_shifts_per_week: 3,
        preferences: %{
          preferred_days_off: ["Saturday"],
          preferred_shifts: ["Afternoon"]
        }
      },
      %{
        id: "emp3",
        name: "Mike Johnson",
        skills: ["Security", "Feeding"],
        employment_type: "fulltime",
        max_shifts_per_week: 6,
        preferences: %{
          preferred_days_off: ["Monday"],
          preferred_shifts: ["Evening"]
        }
      }
    ]

    # Sample initial shifts
    initial_shifts = [
      %{
        id: "Monday-Morning-Week15",
        day: "Monday",
        time_slot: "Morning",
        week_number: 15,
        employee_id: nil,
        role: nil
      },
      %{
        id: "Monday-Afternoon-Week15",
        day: "Monday",
        time_slot: "Afternoon",
        week_number: 15,
        employee_id: nil,
        role: nil
      },
      %{
        id: "Monday-Evening-Week15",
        day: "Monday",
        time_slot: "Evening",
        week_number: 15,
        employee_id: nil,
        role: nil
      }
    ]

    # Sample configuration
    config = %{
      "prioritize_skill_match" => true,
      "respect_preferences" => true,
      "enabled_rules" => [
        %{"name" => "skillMatch"},
        %{"name" => "noConsecutiveShifts"},
        %{"name" => "maxShiftsPerWeek"},
        %{"name" => "preferredDaysOff"}
      ]
    }

    %{employees: employees, initial_shifts: initial_shifts, config: config}
  end

  describe "generate_optimal_schedule/3" do
    test "generates a valid schedule", %{
      employees: employees,
      initial_shifts: initial_shifts,
      config: config
    } do
      # Call the function and extract the schedule
      result = Scheduling.generate_optimal_schedule(initial_shifts, employees, config)

      assert {:ok, schedule} = result
      assert is_list(schedule)
      assert length(schedule) == length(initial_shifts)

      Enum.each(schedule, fn shift ->
        assert Map.has_key?(shift, "employee_id")
        assert Map.has_key?(shift, "role")
        assert shift["employee_id"] != nil
      end)
    end

    test "raises error with nil inputs", %{
      employees: employees,
      initial_shifts: initial_shifts,
      config: config
    } do
      # Nil shifts
      assert {:error, "Shifts cannot be nil"} = Scheduling.generate_optimal_schedule(nil, employees, config)

      # Nil employees
      assert {:error, "No employees available"} = Scheduling.generate_optimal_schedule(initial_shifts, [], config)

      # Nil config
      assert {:error, "Configuration cannot be nil"} = Scheduling.generate_optimal_schedule(initial_shifts, employees, nil)
    end

    test "respects skill matching rule", %{
      employees: employees,
      initial_shifts: initial_shifts,
      config: config
    } do
      {:ok, schedule} = Scheduling.generate_optimal_schedule(initial_shifts, employees, config)

      Enum.each(schedule, fn shift ->
        # Find the assigned employee
        employee = Enum.find(employees, & &1["id"] == shift["employee_id"])
        
        # Check if employee's skills match the shift
        required_skills = case shift["time_slot"] do
          "Morning" -> ["Milking", "Feeding"]
          "Afternoon" -> ["Cleaning", "Maintenance"]
          "Evening" -> ["Security", "Feeding"]
        end

        assert Enum.any?(employee["skills"], fn skill -> skill in required_skills end),
          "Employee #{employee["name"]} does not have required skills for shift #{shift["id"]}"
      end)
    end

    test "limits maximum shifts per week", %{
      employees: employees,
      initial_shifts: initial_shifts,
      config: config
    } do
      {:ok, schedule} = Scheduling.generate_optimal_schedule(initial_shifts, employees, config)

      # Group shifts by employee
      employee_shifts = Enum.group_by(schedule, & &1["employee_id"])

      Enum.each(Map.keys(employee_shifts), fn employee_id ->
        employee = Enum.find(employees, & &1["id"] == employee_id)
        shifts_count = length(employee_shifts[employee_id])

        assert shifts_count <= employee["max_shifts_per_week"], 
          "Employee #{employee["name"]} exceeded maximum shifts per week"
      end)
    end

    test "avoids scheduling on preferred days off", %{
      employees: employees,
      initial_shifts: initial_shifts,
      config: config
    } do
      {:ok, schedule} = Scheduling.generate_optimal_schedule(initial_shifts, employees, config)

      Enum.each(schedule, fn shift ->
        employee = Enum.find(employees, & &1["id"] == shift["employee_id"])
        
        refute shift["day"] in employee["preferences"]["preferred_days_off"],
          "Employee #{employee["name"]} was scheduled on a preferred day off (#{shift["day"]})"
      end)
    end

    test "prevents consecutive shifts", %{
      employees: employees,
      initial_shifts: initial_shifts,
      config: config
    } do
      {:ok, schedule} = Scheduling.generate_optimal_schedule(initial_shifts, employees, config)

      # Group shifts by employee
      employee_shifts = Enum.group_by(schedule, & &1["employee_id"])

      Enum.each(Map.keys(employee_shifts), fn employee_id ->
        employee_week_shifts = employee_shifts[employee_id]
        days_with_shifts = Enum.map(employee_week_shifts, & &1["day"])
        
        assert length(Enum.uniq(days_with_shifts)) == length(days_with_shifts), 
          "Employee #{employee_id} has consecutive shifts on the same day"
      end)
    end

    test "handles edge case with no employees", %{
      initial_shifts: initial_shifts,
      config: config
    } do
      result = Scheduling.generate_optimal_schedule(initial_shifts, [], config)
      assert {:error, "No employees available"} = result
    end

    test "handles edge case with no shifts", %{
      employees: employees,
      config: config
    } do
      result = Scheduling.generate_optimal_schedule([], employees, config)
      assert {:error, "Shifts cannot be nil"} = result
    end

    test "handles edge case with no configuration", %{
      employees: employees,
      initial_shifts: initial_shifts
    } do
      result = Scheduling.generate_optimal_schedule(initial_shifts, employees, nil)
      assert {:error, "Configuration cannot be nil"} = result
    end
  end

  describe "can_assign_employee_to_shift?/5" do
    test "validates skill matching", %{
      employees: employees,
      initial_shifts: initial_shifts,
      config: config
    } do
      # Extract enabled rules
      enabled_rules = config["enabled_rules"]

      Enum.each(initial_shifts, fn shift ->
        Enum.each(employees, fn employee ->
          result = Scheduling.can_assign_employee_to_shift?(
            employee, 
            shift["day"], 
            shift["time_slot"], 
            [], 
            enabled_rules
          )

          # Validate skill matching rule
          skill_match_rule = Enum.find(enabled_rules, & &1["name"] == "skillMatch")
          
          if skill_match_rule do
            required_skills = case shift["time_slot"] do
              "Morning" -> ["Milking", "Feeding"]
              "Afternoon" -> ["Cleaning", "Maintenance"]
              "Evening" -> ["Security", "Feeding"]
            end

            assert (Enum.any?(employee["skills"], fn skill -> skill in required_skills end) == result),
              "Skill matching validation failed for #{employee["name"]} on #{shift["id"]}"
          end
        end)
      end)
    end
  end
end
