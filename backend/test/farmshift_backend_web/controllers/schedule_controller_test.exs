defmodule FarmshiftBackendWeb.ScheduleControllerTest do
  use FarmshiftBackendWeb.ConnCase

  alias FarmshiftBackend.Employees.Employee
  alias FarmshiftBackend.Repo

  setup %{conn: conn} do
    # Ensure a clean database state
    Repo.delete_all(Employee)

    # Create test employees with various skills and preferences
    employees = [
      %{
        name: "John Doe",
        role: "Farm Worker",
        skills: ["Milking", "Feeding"],
        employment_type: "fulltime",
        max_shifts_per_week: 5,
        preferred_days_off: ["Sunday"],
        preferred_shifts: ["Morning"]
      },
      %{
        name: "Jane Smith",
        role: "Farm Manager",
        skills: ["Cleaning", "Maintenance"],
        employment_type: "parttime",
        max_shifts_per_week: 3,
        preferred_days_off: ["Saturday"],
        preferred_shifts: ["Afternoon"]
      },
      %{
        name: "Mike Johnson",
        role: "Farm Hand",
        skills: ["Security", "Feeding"],
        employment_type: "fulltime",
        max_shifts_per_week: 6,
        preferred_days_off: ["Monday"],
        preferred_shifts: ["Evening"]
      }
    ]

    # Insert employees into the database
    Enum.each(employees, fn employee_attrs ->
      %Employee{}
      |> Employee.changeset(employee_attrs)
      |> Repo.insert!()
    end)

    %{conn: conn}
  end

  describe "generate_schedule/2" do
    test "generates a schedule for a specific week", %{conn: conn} do
      # Prepare a valid configuration
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

      # Send request to generate schedule
      conn = post(conn, ~p"/api/schedule/generate", %{
        "week_number" => 15,
        "config" => config
      })

      # Assert response
      response = json_response(conn, 200)
      
      assert Map.has_key?(response, "schedule")
      assert Map.has_key?(response, "week_number")
      assert Map.has_key?(response, "message")
      
      schedule = response["schedule"]

      # Validate schedule structure
      assert is_list(schedule)
      assert length(schedule) > 0

      # Check schedule entries
      Enum.each(schedule, fn shift ->
        assert Map.has_key?(shift, "id")
        assert Map.has_key?(shift, "day")
        assert Map.has_key?(shift, "time_slot")
        assert Map.has_key?(shift, "week_number")
        assert Map.has_key?(shift, "employee_id")
        assert Map.has_key?(shift, "role")
        
        assert shift["week_number"] == 15
        assert shift["day"] in ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        assert shift["time_slot"] in ["Morning", "Afternoon", "Evening"]
        assert shift["employee_id"] != nil
      end)
    end

    test "handles invalid configuration", %{conn: conn} do
      # Test with invalid configuration
      conn = post(conn, ~p"/api/schedule/generate", %{
        "week_number" => 15,
        "config" => %{}
      })

      # Assert error response
      assert %{"error" => "Missing enabled rules"} = json_response(conn, 422)
    end

    test "handles scenario with no active employees", %{conn: conn} do
      # Delete all employees to simulate no active employees
      Repo.delete_all(Employee)

      config = %{
        "prioritize_skill_match" => true,
        "enabled_rules" => [
          %{"name" => "skillMatch"}
        ]
      }

      conn = post(conn, ~p"/api/schedule/generate", %{
        "week_number" => 15,
        "config" => config
      })

      # Assert error response
      assert %{"error" => "No available employees"} = json_response(conn, 422)
    end
  end
end
