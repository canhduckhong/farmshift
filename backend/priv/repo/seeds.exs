# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     FarmshiftBackend.Repo.insert!(%FarmshiftBackend.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias FarmshiftBackend.Accounts
alias FarmshiftBackend.Repo

# Clear existing users in development
if Mix.env() == :dev do
  Repo.delete_all(FarmshiftBackend.Accounts.User)
  
  # Create admin user
  {:ok, admin} = Accounts.create_user(%{
    name: "Admin User",
    email: "admin@farmshift.com",
    password: "password123",
    role: "admin"
  })
  
  IO.puts("Created admin user: #{admin.email}")
  
  # Create regular employees
  employees = [
    %{name: "John Doe", email: "john@farmshift.com", password: "password123", role: "employee"},
    %{name: "Jane Smith", email: "jane@farmshift.com", password: "password123", role: "employee"},
    %{name: "Lars Nielsen", email: "lars@farmshift.com", password: "password123", role: "employee"}
  ]
  
  Enum.each(employees, fn employee_data ->
    {:ok, employee} = Accounts.create_user(employee_data)
    IO.puts("Created employee: #{employee.email}")
  end)
  
  IO.puts("\nSeeding completed successfully!")
end
