defmodule FarmshiftBackendWeb.EmployeeJSON do
  alias FarmshiftBackend.Employees.Employee

  def index(%{employees: employees}) do
    %{data: for(employee <- employees, do: data(employee))}
  end

  def show(%{employee: employee}) do
    %{data: data(employee)}
  end

  def data(%Employee{} = employee) do
    %{
      id: employee.id,
      name: employee.name,
      role: employee.role,
      employment_type: employee.employment_type,
      skills: employee.skills,
      max_shifts_per_week: employee.max_shifts_per_week
    }
  end

  def data(_), do: nil
end
