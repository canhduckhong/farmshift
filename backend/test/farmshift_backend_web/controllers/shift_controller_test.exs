defmodule FarmshiftBackendWeb.ShiftControllerTest do
  use FarmshiftBackendWeb.ConnCase

  alias FarmshiftBackend.Shifts
  alias FarmshiftBackend.Employees

  setup %{conn: conn} do
    # Create an employee to use for shift assignments
    {:ok, employee} = Employees.create_employee(%{
      name: "Test Employee",
      role: "Worker",
      employment_type: "fulltime",
      skills: ["Milking"]
    })

    %{conn: conn, employee: employee}
  end

  describe "index" do
    test "lists all shifts", %{conn: conn, employee: employee} do
      # Create some test shifts
      {:ok, _shift1} = Shifts.create_shift(%{
        day: "Monday",
        time_slot: "Morning",
        employee_id: employee.id
      })
      {:ok, _shift2} = Shifts.create_shift(%{
        day: "Tuesday",
        time_slot: "Afternoon",
        employee_id: employee.id
      })

      conn = get(conn, ~p"/api/shifts")

      assert %{"data" => shifts} = json_response(conn, 200)
      assert length(shifts) >= 2
    end
  end

  describe "show" do
    test "shows a specific shift", %{conn: conn, employee: employee} do
      {:ok, shift} = Shifts.create_shift(%{
        day: "Wednesday",
        time_slot: "Evening",
        employee_id: employee.id,
        notes: "Test shift"
      })

      conn = get(conn, ~p"/api/shifts/#{shift.id}")

      assert %{"data" => response_shift} = json_response(conn, 200)
      assert response_shift["id"] == shift.id
      assert response_shift["day"] == "Wednesday"
      assert response_shift["time_slot"] == "Evening"
      assert response_shift["notes"] == "Test shift"
    end
  end

  describe "create" do
    test "creates a new shift", %{conn: conn, employee: employee} do
      shift_params = %{
        day: "Friday",
        time_slot: "Morning",
        employee_id: employee.id,
        notes: "New shift"
      }

      conn = post(conn, ~p"/api/shifts", shift: shift_params)

      assert %{"data" => response_shift} = json_response(conn, 201)
      assert response_shift["day"] == "Friday"
      assert response_shift["time_slot"] == "Morning"
      assert response_shift["notes"] == "New shift"
    end
  end

  describe "update" do
    test "updates an existing shift", %{conn: conn, employee: employee} do
      {:ok, shift} = Shifts.create_shift(%{
        day: "Monday",
        time_slot: "Morning",
        employee_id: employee.id
      })

      update_params = %{
        notes: "Updated shift notes",
        is_confirmed: true
      }

      conn = put(conn, ~p"/api/shifts/#{shift.id}", shift: update_params)

      assert %{"data" => response_shift} = json_response(conn, 200)
      assert response_shift["notes"] == "Updated shift notes"
      assert response_shift["is_confirmed"] == true
    end
  end

  describe "delete" do
    test "deletes a shift", %{conn: conn, employee: employee} do
      {:ok, shift} = Shifts.create_shift(%{
        day: "Tuesday",
        time_slot: "Afternoon",
        employee_id: employee.id
      })

      conn = delete(conn, ~p"/api/shifts/#{shift.id}")

      assert response(conn, 204)

      # Verify the shift was deleted
      assert_raise Ecto.NoResultsError, fn ->
        Shifts.get_shift!(shift.id)
      end
    end
  end

  describe "assign" do
    test "assigns a shift to an employee", %{conn: conn, employee: employee} do
      conn = post(conn, ~p"/api/shifts/assign", %{
        employee_id: employee.id,
        day: "Thursday",
        time_slot: "Morning",
        notes: "Assigned shift"
      })

      assert %{"data" => response_shift} = json_response(conn, 201)
      assert response_shift["day"] == "Thursday"
      assert response_shift["time_slot"] == "Morning"
      assert response_shift["notes"] == "Assigned shift"
      assert response_shift["employee"]["id"] == employee.id
    end
  end

  describe "unassign" do
    test "unassigns a shift", %{conn: conn, employee: employee} do
      {:ok, shift} = Shifts.create_shift(%{
        day: "Friday",
        time_slot: "Evening",
        employee_id: employee.id,
        is_confirmed: true
      })

      conn = delete(conn, ~p"/api/shifts/unassign/#{shift.id}")

      assert %{"data" => response_shift} = json_response(conn, 200)
      assert response_shift["employee_id"] == nil
      assert response_shift["is_confirmed"] == false
    end
  end
end
