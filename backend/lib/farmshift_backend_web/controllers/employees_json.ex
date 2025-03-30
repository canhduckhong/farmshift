defmodule FarmshiftBackendWeb.EmployeesJSON do
  def index(%{employees: employees}) do
    %{data: for(employee <- employees, do: data(employee))}
  end

  def show(%{employee: employee}) do
    %{data: data(employee)}
  end

  defp data(employee) do
    %{
      id: employee.id,
      name: employee.name,
      role: employee.role,
      employmentType: employee.employmentType,
      skills: employee.skills,
      preferences: employee.preferences,
      maxShiftsPerWeek: employee.maxShiftsPerWeek
    }
  end
end
