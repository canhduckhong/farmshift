defmodule FarmshiftBackendWeb.EmployeeJSON do
  alias FarmshiftBackend.Employees.Employee

  def index(%{employees: employees}) do
    %{data: for(employee <- employees, do: data(employee))}
  end

  def show(%{employee: employee}) do
    %{data: data(employee)}
  end

  def data(%Employee{} = employee) do
    Employee.to_response(employee)
  end
end
