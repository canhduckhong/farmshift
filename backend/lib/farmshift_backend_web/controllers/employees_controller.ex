defmodule FarmshiftBackendWeb.EmployeesController do
  use FarmshiftBackendWeb, :controller

  alias FarmshiftBackend.Employees
  alias FarmshiftBackend.Employees.Employee

  action_fallback FarmshiftBackendWeb.FallbackController

  def index(conn, _params) do
    employees = Employees.list_employees()
    render(conn, :index, employees: Enum.map(employees, &Employee.to_response/1))
  end

  def create(conn, %{"employee" => employee_params}) do
    with {:ok, %Employee{} = employee} <- Employees.create_employee(employee_params) do
      conn
      |> put_status(:created)
      |> render(:show, employee: Employee.to_response(employee))
    end
  end

  def show(conn, %{"id" => id}) do
    employee = Employees.get_employee!(id)
    render(conn, :show, employee: Employee.to_response(employee))
  end

  def update(conn, %{"id" => id, "employee" => employee_params}) do
    employee = Employees.get_employee!(id)

    with {:ok, %Employee{} = employee} <- Employees.update_employee(employee, employee_params) do
      render(conn, :show, employee: Employee.to_response(employee))
    end
  end

  def delete(conn, %{"id" => id}) do
    employee = Employees.get_employee!(id)

    with {:ok, %Employee{}} <- Employees.delete_employee(employee) do
      send_resp(conn, :no_content, "")
    end
  end
end
