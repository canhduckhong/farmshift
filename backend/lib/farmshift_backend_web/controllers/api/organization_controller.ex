defmodule FarmshiftBackendWeb.API.OrganizationController do
  use FarmshiftBackendWeb, :controller

  alias FarmshiftBackend.Organizations
  alias FarmshiftBackend.Organizations.Organization

  action_fallback FarmshiftBackendWeb.FallbackController

  def index(conn, _params) do
    # Get the current user from the token
    current_user = conn.assigns.current_user

    # Get organizations where the user is a member
    organizations = Organizations.list_user_organizations(current_user.id)
    render(conn, :index, organizations: organizations)
  end

  def create(conn, %{"organization" => organization_params}) do
    # Get the current user from the token
    current_user = conn.assigns.current_user

    with {:ok, %Organization{} = organization} <- Organizations.create_organization(organization_params),
         # Automatically add the creator as an admin
         {:ok, _membership} <- Organizations.add_user_to_organization(organization.id, current_user.id, "admin") do
      conn
      |> put_status(:created)
      |> put_resp_header("location", "/api/organizations/#{organization.id}")
      |> render(:show, organization: {organization, "admin"})
    end
  end

  def show(conn, %{"id" => id}) do
    # Get the current user from the token
    current_user = conn.assigns.current_user

    # Get organization
    organization = Organizations.get_organization!(id)

    # Check if user is a member of the organization
    case Organizations.get_user_role(organization.id, current_user.id) do
      {:ok, role} ->
        conn
        |> put_status(200)
        |> render(:show, organization: {organization, role})
      {:error, :not_found} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "You do not have access to this organization"})
    end
  end

  def update(conn, %{"id" => id, "organization" => organization_params}) do
    # Get the current user from the token
    current_user = conn.assigns.current_user

    # Get organization
    organization = Organizations.get_organization!(id)

    # Check if user has admin role in this organization
    case Organizations.get_user_role(organization.id, current_user.id) do
      {:ok, "admin"} ->
        with {:ok, updated_organization} <- Organizations.update_organization(organization, organization_params) do
          conn
          |> put_status(200)
          |> render(:update, organization: {updated_organization, "admin"})
        end
      {:ok, _role} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "You do not have permission to update this organization"})
      {:error, :not_found} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "You do not have permission to update this organization"})
    end
  end

  def delete(conn, %{"id" => id}) do
    # Get the current user from the token
    current_user = conn.assigns.current_user

    # Get organization
    organization = Organizations.get_organization!(id)

    # Check if user has admin role in this organization
    case Organizations.get_user_role(organization.id, current_user.id) do
      {:ok, "admin"} ->
        with {:ok, _} <- Organizations.delete_organization(organization) do
          send_resp(conn, :no_content, "")
        end
      {:ok, _role} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "You do not have permission to delete this organization"})
      {:error, :not_found} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "You do not have permission to delete this organization"})
    end
  end

  def members(conn, %{"id" => id}) do
    # Get the current user from the token
    current_user = conn.assigns.current_user

    # Get organization
    organization = Organizations.get_organization!(id)

    # Check if user has access to this organization
    case Organizations.get_user_role(organization.id, current_user.id) do
      nil ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "You do not have access to this organization"})
      _role ->
        members = Organizations.list_organization_members(organization.id)
        render(conn, :members, members: members)
    end
  end

  def add_member(conn, %{"id" => id, "user_id" => user_id, "role" => role}) do
    # Get the current user from the token
    current_user = conn.assigns.current_user

    # Get organization
    organization = Organizations.get_organization!(id)

    # Check if user has admin role in this organization
    case Organizations.get_user_role(organization.id, current_user.id) do
      {:ok, "admin"} ->
        with {:ok, _} <- Organizations.add_user_to_organization(organization.id, user_id, role) do
          send_resp(conn, :no_content, "")
        end
      _ ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "You do not have permission to add members"})
    end
  end

  def remove_member(conn, %{"id" => id, "user_id" => user_id}) do
    # Get the current user from the token
    current_user = conn.assigns.current_user

    # Get organization
    organization = Organizations.get_organization!(id)

    # Check if user has admin role in this organization
    case Organizations.get_user_role(organization.id, current_user.id) do
      {:ok, "admin"} ->
        with {:ok, _} <- Organizations.remove_user_from_organization(organization.id, user_id) do
          send_resp(conn, :no_content, "")
        end
      _ ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "You do not have permission to remove members"})
    end
  end

  def update_member_role(conn, %{"id" => id, "user_id" => user_id, "role" => role}) do
    # Get the current user from the token
    current_user = conn.assigns.current_user

    # Get organization
    organization = Organizations.get_organization!(id)

    # Check if user has admin role in this organization
    case Organizations.get_user_role(organization.id, current_user.id) do
      {:ok, "admin"} ->
        with {:ok, _} <- Organizations.update_user_role(organization.id, user_id, role) do
          send_resp(conn, :no_content, "")
        end
      _ ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "You do not have permission to update member roles"})
    end
  end

  def update_features(conn, %{"id" => id, "features" => features}) do
    # Get the current user from the token
    current_user = conn.assigns.current_user

    # Get organization
    organization = Organizations.get_organization!(id)

    # Check if user has admin role in this organization
    case Organizations.get_user_role(organization.id, current_user.id) do
      "admin" ->
        with {:ok, updated_organization} <- Organizations.update_features(organization.id, features) do
          render(conn, :show, organization: {updated_organization, "admin"})
        end
      _ ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "You must be an admin to update features"})
    end
  end
end
