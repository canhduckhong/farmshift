defmodule FarmshiftBackend.Employees do
  @moduledoc """
  Context for managing employees.
  Provides CRUD operations for employee records.
  """

  import Ecto.Query, warn: false
  alias FarmshiftBackend.Repo

  alias FarmshiftBackend.Employees.Employee

  @doc """
  Returns the list of employees.

  ## Examples

      iex> list_employees()
      [%Employee{}, ...]

  """
  def list_employees(params \\ %{}) do
    Employee
    |> filter_employees(params)
    |> Repo.all()
  end

  defp filter_employees(query, params) do
    Enum.reduce(params, query, fn
      {:role, role}, q -> where(q, [e], e.role == ^role)
      {:employment_type, type}, q -> where(q, [e], e.employment_type == ^type)
      {:skills, skills}, q -> where(q, [e], fragment("? && ?", e.skills, ^skills))
      _, q -> q
    end)
  end

  @doc """
  Gets a single employee.

  Raises `Ecto.NoResultsError` if the Employee does not exist.

  ## Examples

      iex> get_employee!("uuid-here")
      %Employee{}

      iex> get_employee!("non-existent-uuid")
      ** (Ecto.NoResultsError)

  """
  def get_employee!(id) do
    # Validate that the ID is a valid UUID format
    case Ecto.UUID.cast(id) do
      {:ok, uuid} -> Repo.get!(Employee, uuid)
      :error -> raise Ecto.NoResultsError, queryable: Employee, id: id
    end
  end

  @doc """
  Creates an employee.

  ## Examples

      iex> create_employee(%{name: "John Doe", role: "Worker"})
      {:ok, %Employee{}}

      iex> create_employee(%{name: ""})
      {:error, %Ecto.Changeset{}}

  """
  def create_employee(attrs \\ %{}) do
    %Employee{}
    |> Employee.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an employee.

  ## Examples

      iex> update_employee(employee, %{name: "New Name"})
      {:ok, %Employee{}}

      iex> update_employee(employee, %{role: ""})
      {:error, %Ecto.Changeset{}}

  """
  def update_employee(%Employee{} = employee, attrs) do
    employee
    |> Employee.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an employee.

  ## Examples

      iex> delete_employee(employee)
      {:ok, %Employee{}}

      iex> delete_employee(employee)
      {:error, %Ecto.Changeset{}}

  """
  def delete_employee(%Employee{} = employee) do
    Repo.delete(employee)
  end
end
