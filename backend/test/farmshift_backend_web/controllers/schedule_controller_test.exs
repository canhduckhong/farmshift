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
