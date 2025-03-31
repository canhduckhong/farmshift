defmodule FarmshiftBackend.Accounts do
  @moduledoc """
  The Accounts context.
  Handles user management and authentication.
  """

  import Ecto.Query, warn: false
  alias FarmshiftBackend.Repo

  alias FarmshiftBackend.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!("uuid-here")
      %User{}

      iex> get_user!("non-existent-uuid")
      ** (Ecto.NoResultsError)

  """
  def get_user!(id) do
    # Validate that the ID is a valid UUID format
    case Ecto.UUID.cast(id) do
      {:ok, uuid} -> Repo.get!(User, uuid)
      :error -> raise Ecto.NoResultsError, queryable: User, id: id
    end
  end

  @doc """
  Gets a single user by email.
  Returns nil if the user does not exist.
  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Creates a user with password hashing.

  ## Examples

      iex> create_user(%{email: "user@example.com", password: "password123"})
      {:ok, %User{}}

      iex> create_user(%{email: "invalid"})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user's profile information (excluding password).

  ## Examples

      iex> update_user(user, %{name: "New Name"})
      {:ok, %User{}}

      iex> update_user(user, %{email: "invalid"})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a user's password.

  ## Examples

      iex> update_user_password(user, %{password: "new_password"})
      {:ok, %User{}}

      iex> update_user_password(user, %{password: "short"})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(%User{} = user, attrs) do
    user
    |> User.password_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Authenticates a user by email and password.
  Returns {:ok, user} if credentials are valid, {:error, :unauthorized} otherwise.
  """
  def authenticate_user(email, password) do
    user = get_user_by_email(email)

    cond do
      user && Bcrypt.verify_pass(password, user.password_hash) ->
        {:ok, user}
      true ->
        {:error, :unauthorized}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.update_changeset(user, attrs)
  end

  @doc """
  Checks if a user exists with the given email.
  """
  def user_exists?(email) do
    Repo.exists?(from u in User, where: u.email == ^email)
  end
end
