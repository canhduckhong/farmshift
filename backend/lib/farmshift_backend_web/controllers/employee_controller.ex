defmodule FarmshiftBackendWeb.EmployeeController do
  use FarmshiftBackendWeb, :controller
  alias FarmshiftBackend.Employees
  alias FarmshiftBackend.Employees.Employee

  def index(conn, params) do
    employees = Employees.list_employees(params)
    render(conn, :index, employees: employees)
  end

  def show(conn, %{"id" => id}) do
    employee = Employees.get_employee!(id)
    render(conn, :show, employee: employee)
  end

  def create(conn, %{"employee" => employee_params}) do
    with {:ok, %Employee{} = employee} <- Employees.create_employee(employee_params) do
      conn
      |> put_status(:created)
      |> render(:show, employee: employee)
    end
  end

  def update(conn, %{"id" => id, "employee" => employee_params}) do
    employee = Employees.get_employee!(id)

    with {:ok, %Employee{} = employee} <- Employees.update_employee(employee, employee_params) do
      render(conn, :show, employee: employee)
    end
  end

  def delete(conn, %{"id" => id}) do
    employee = Employees.get_employee!(id)

    with {:ok, %Employee{}} <- Employees.delete_employee(employee) do
      send_resp(conn, :no_content, "")
    end
  end
end
