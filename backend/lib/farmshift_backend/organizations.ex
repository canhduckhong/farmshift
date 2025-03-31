defmodule FarmshiftBackend.Organizations do
  @moduledoc """
  The Organizations context.
  Provides functions for managing organizations, memberships, and permissions.
  """

  import Ecto.Query, warn: false
  alias FarmshiftBackend.Repo

  alias FarmshiftBackend.Organizations.Organization
  alias FarmshiftBackend.Organizations.OrganizationUser
  alias FarmshiftBackend.Accounts.User

  @doc """
  Returns the list of organizations.

  ## Examples

      iex> list_organizations()
      [%Organization{}, ...]

  """
  def list_organizations do
    Repo.all(Organization)
  end

  @doc """
  Gets a single organization.

  Raises `Ecto.NoResultsError` if the Organization does not exist.

  ## Examples

      iex> get_organization!(123)
      %Organization{}

      iex> get_organization!(456)
      ** (Ecto.NoResultsError)

  """
  def get_organization!(id), do: Repo.get!(Organization, id)

  @doc """
  Creates a organization.

  ## Examples

      iex> create_organization(%{field: value})
      {:ok, %Organization{}}

      iex> create_organization(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_organization(attrs \\ %{}) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a organization.

  ## Examples

      iex> update_organization(organization, %{field: new_value})
      {:ok, %Organization{}}

      iex> update_organization(organization, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_organization(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a organization.

  ## Examples

      iex> delete_organization(organization)
      {:ok, %Organization{}}

      iex> delete_organization(organization)
      {:error, %Ecto.Changeset{}}

  """
  def delete_organization(%Organization{} = organization) do
    Repo.delete(organization)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking organization changes.

  ## Examples

      iex> change_organization(organization)
      %Ecto.Changeset{data: %Organization{}}

  """
  def change_organization(%Organization{} = organization, attrs \\ %{}) do
    Organization.changeset(organization, attrs)
  end

  @doc """
  Returns a list of organizations for a given user.
  """
  def list_user_organizations(user_id) do
    query = from o in Organization,
            join: ou in OrganizationUser, on: ou.organization_id == o.id,
            where: ou.user_id == ^user_id,
            select: {o, ou.role}
            
    Repo.all(query)
  end

  @doc """
  Adds a user to an organization with the specified role.
  """
  def add_user_to_organization(organization_id, user_id, role) do
    %OrganizationUser{}
    |> OrganizationUser.changeset(%{
      organization_id: organization_id,
      user_id: user_id,
      role: role
    })
    |> Repo.insert()
  end

  @doc """
  Removes a user from an organization.
  Returns {:ok, _} if successful, or {:error, :not_found} if the user or organization is not found.
  """
  def remove_user_from_organization(organization_id, user_id) do
    query = from ou in OrganizationUser,
            where: ou.organization_id == ^organization_id and ou.user_id == ^user_id
            
    case Repo.delete_all(query) do
      {0, _} -> {:error, :not_found}
      {1, _} -> {:ok, nil}
    end
  end
  
  @doc """
  Gets a user's role in an organization.
  Returns {:error, :not_found} if the user is not a member of the organization.
  """
  def get_user_role(organization_id, user_id) do
    query = from ou in OrganizationUser,
            where: ou.organization_id == ^organization_id and ou.user_id == ^user_id,
            select: ou.role
            
    case Repo.one(query) do
      nil -> {:error, :not_found}
      role -> {:ok, role}
    end
  end

  @doc """
  Updates a user's role in an organization.
  """
  def update_user_role(organization_id, user_id, role) do
    query = from ou in OrganizationUser,
            where: ou.organization_id == ^organization_id and ou.user_id == ^user_id
            
    case Repo.one(query) do
      nil -> {:error, :not_found}
      organization_user ->
        organization_user
        |> OrganizationUser.changeset(%{role: role})
        |> Repo.update()
    end
  end

  @doc """
  Checks if a user has permission to perform an action in an organization.
  """
  def has_permission?(organization_id, user_id, permission) do
    with role when not is_nil(role) <- get_user_role(organization_id, user_id),
         true <- has_role_permission?(role, permission) do
      true
    else
      _ -> false
    end
  end

  # Role-based permission mapping
  defp has_role_permission?("admin", _permission), do: true
  defp has_role_permission?("scheduler", permission) do
    scheduler_permissions = [
      :view_organization, 
      :manage_schedule,
      :view_employees,
      :edit_schedule
    ]
    permission in scheduler_permissions
  end
  defp has_role_permission?("viewer", permission) do
    viewer_permissions = [
      :view_organization,
      :view_schedule
    ]
    permission in viewer_permissions
  end
  defp has_role_permission?(_, _), do: false

  @doc """
  Checks if a feature is enabled for an organization.
  """
  def feature_enabled?(organization_id, feature_name) do
    organization = get_organization!(organization_id)
    Map.get(organization.features, feature_name, false)
  end

  @doc """
  Updates features for an organization.
  """
  def update_features(organization_id, features) do
    organization = get_organization!(organization_id)
    updated_features = Map.merge(organization.features || %{}, features)
    
    update_organization(organization, %{features: updated_features})
  end

  @doc """
  Lists all members of an organization with their roles.
  """
  def list_organization_members(organization_id) do
    query = from ou in OrganizationUser,
            join: u in User, on: u.id == ou.user_id,
            where: ou.organization_id == ^organization_id,
            preload: [user: u]
            
    Repo.all(query)
  end

  @doc """
  Counts the number of admins in an organization.
  """
  def count_organization_admins(organization_id) do
    query = from ou in OrganizationUser,
            where: ou.organization_id == ^organization_id and ou.role == "admin",
            select: count(ou.id)
            
    Repo.one(query)
  end
end