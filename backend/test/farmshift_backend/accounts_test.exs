defmodule FarmshiftBackend.AccountsTest do
  use FarmshiftBackend.DataCase

  alias FarmshiftBackend.Accounts

  describe "users" do
    alias FarmshiftBackend.Accounts.User

    import FarmshiftBackend.AccountsFixtures

    @invalid_attrs %{
      name: nil, 
      role: nil, 
      email: nil, 
      password: nil, 
      password_confirmation: nil
    }

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{
        name: "John Doe", 
        role: "employee", 
        email: "john.doe@example.com", 
        password: "secure_password123",
        password_confirmation: "secure_password123"
      }

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.name == "John Doe"
      assert user.role == "employee"
      assert user.email == "john.doe@example.com"
      assert user.password_hash != nil
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{
        name: "Updated Name", 
        role: "admin", 
        email: "updated.email@example.com"
      }

      assert {:ok, %User{} = updated_user} = Accounts.update_user(user, update_attrs)
      assert updated_user.name == "Updated Name"
      assert updated_user.role == "admin"
      assert updated_user.email == "updated.email@example.com"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end
  end
end
