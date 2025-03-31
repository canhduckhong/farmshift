defmodule FarmshiftBackendWeb.API.OrganizationControllerTest do
  use FarmshiftBackendWeb.ConnCase

  alias FarmshiftBackend.Organizations
  alias FarmshiftBackend.Accounts

  setup %{conn: conn} do
    # Create a user for authentication
    {:ok, user} = Accounts.create_user(%{
      email: "test_user@example.com",
      password: "password123",
      name: "Test User"
    })

    # Generate an authentication token
    {:ok, token, _claims} = FarmshiftBackend.Auth.Guardian.encode_and_sign(user)

    # Prepare a connection with the authentication header
    conn = conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> put_req_header("content-type", "application/json")

    %{conn: conn, user: user, token: token}
  end

  describe "index" do
    test "lists organizations for the current user", %{conn: conn, user: user} do
      # Create an organization and add the user to it
      {:ok, organization} = Organizations.create_organization(%{
        name: "Test Org",
        description: "A test organization"
      })
      {:ok, _} = Organizations.add_user_to_organization(organization.id, user.id, "admin")

      # Make the request
      conn = get(conn, ~p"/api/organizations")

      # Assert response
      assert json_response(conn, 200)["data"] != []
      assert length(json_response(conn, 200)["data"]) == 1
      assert hd(json_response(conn, 200)["data"])["name"] == "Test Org"
    end
  end

  describe "create" do
    test "creates a new organization", %{conn: conn, user: user} do
      # Prepare organization params
      org_params = %{
        name: "New Test Organization",
        description: "A brand new test organization"
      }

      # Make the request
      conn = post(conn, ~p"/api/organizations", organization: org_params)

      # Assert response
      assert %{"id" => id, "name" => "New Test Organization"} = json_response(conn, 201)["data"]

      # Verify the user is added as an admin
      assert {:ok, "admin"} = Organizations.get_user_role(id, user.id)

      # Check location header
      assert [location] = get_resp_header(conn, "location")
      assert location == "/api/organizations/#{id}"
    end

    test "returns error for invalid organization params", %{conn: conn} do
      # Prepare invalid organization params
      org_params = %{
        name: "", # Empty name should fail validation
        description: "A brand new test organization"
      }

      # Make the request
      conn = post(conn, ~p"/api/organizations", organization: org_params)

      # Assert error response
      assert %{"errors" => _} = json_response(conn, 422)
    end
  end

  describe "show" do
    test "shows a specific organization the user is a member of", %{conn: conn, user: user} do
      # Create an organization and add the user to it
      {:ok, organization} = Organizations.create_organization(%{
        name: "Detailed Org",
        description: "An organization with details"
      })
      {:ok, _} = Organizations.add_user_to_organization(organization.id, user.id, "admin")

      # Make the request
      conn = get(conn, ~p"/api/organizations/#{organization.id}")

      # Assert response
      assert %{
        "id" => id,
        "name" => "Detailed Org",
        "user_role" => "admin"
      } = json_response(conn, 200)["data"]
      assert id == organization.id
    end

    test "returns forbidden for organization user is not a member of", %{conn: conn} do
      # Create an organization without adding the current user
      {:ok, organization} = Organizations.create_organization(%{
        name: "Restricted Org",
        description: "An organization with restricted access"
      })

      # Make the request
      conn = get(conn, ~p"/api/organizations/#{organization.id}")

      # Assert forbidden response
      assert %{"error" => "You do not have access to this organization"} = json_response(conn, 403)
    end
  end

  describe "update" do
    test "updates an existing organization", %{conn: conn, user: user} do
      # Create an organization and add the user as an admin
      {:ok, organization} = Organizations.create_organization(%{
        name: "Original Org",
        description: "An organization to be updated"
      })
      {:ok, _} = Organizations.add_user_to_organization(organization.id, user.id, "admin")

      # Prepare update params
      update_params = %{
        name: "Updated Organization Name",
        description: "Updated description"
      }

      # Make the request
      conn = put(conn, ~p"/api/organizations/#{organization.id}", organization: update_params)

      # Assert response
      assert %{
        "name" => "Updated Organization Name",
        "description" => "Updated description"
      } = json_response(conn, 200)["data"]
    end

    test "prevents non-admin users from updating", %{conn: conn, user: user} do
      # Create an organization and add the user as a viewer
      {:ok, organization} = Organizations.create_organization(%{
        name: "Viewer Org",
        description: "An organization with limited access"
      })
      {:ok, _} = Organizations.add_user_to_organization(organization.id, user.id, "viewer")

      # Prepare update params
      update_params = %{
        name: "Unauthorized Update",
        description: "Should not be allowed"
      }

      # Make the request
      conn = put(conn, ~p"/api/organizations/#{organization.id}", organization: update_params)

      # Assert forbidden response
      assert %{"error" => "You do not have permission to update this organization"} = json_response(conn, 403)
    end
  end

  describe "delete" do
    test "deletes an organization the user owns", %{conn: conn, user: user} do
      # Create an organization and add the user as an admin
      {:ok, organization} = Organizations.create_organization(%{
        name: "Deletable Org",
        description: "An organization to be deleted"
      })
      {:ok, _} = Organizations.add_user_to_organization(organization.id, user.id, "admin")

      # Make the request
      conn = delete(conn, ~p"/api/organizations/#{organization.id}")

      # Assert response
      assert response(conn, 204)

      # Verify organization is deleted
      assert_raise Ecto.NoResultsError, fn ->
        Organizations.get_organization!(organization.id)
      end
    end

    test "prevents non-admin users from deleting", %{conn: conn, user: user} do
      # Create an organization and add the user as a viewer
      {:ok, organization} = Organizations.create_organization(%{
        name: "Undeletable Org",
        description: "An organization with limited access"
      })
      {:ok, _} = Organizations.add_user_to_organization(organization.id, user.id, "viewer")

      # Make the request
      conn = delete(conn, ~p"/api/organizations/#{organization.id}")

      # Assert forbidden response
      assert %{"error" => "You do not have permission to delete this organization"} = json_response(conn, 403)
    end
  end

  describe "add_member" do
    test "admin can add a new member to the organization", %{conn: conn, user: user} do
      # Create an organization and add the current user as an admin
      {:ok, organization} = Organizations.create_organization(%{
        name: "Membership Org",
        description: "An organization for testing membership"
      })
      {:ok, _} = Organizations.add_user_to_organization(organization.id, user.id, "admin")

      # Create another user to add to the organization
      {:ok, new_member} = Accounts.create_user(%{
        email: "new_member@example.com",
        password: "password123",
        name: "New Member"
      })

      # Prepare member addition params
      member_params = %{
        user_id: new_member.id,
        role: "viewer"
      }

      # Make the request
      conn = post(conn, ~p"/api/organizations/#{organization.id}/members", member_params)

      # Assert response
      assert response(conn, 204)

      # Verify member was added
      assert {:ok, "viewer"} = Organizations.get_user_role(organization.id, new_member.id)
    end

    test "prevents non-admin users from adding members", %{conn: conn, user: user} do
      # Create an organization and add the current user as a viewer
      {:ok, organization} = Organizations.create_organization(%{
        name: "Restricted Membership Org",
        description: "An organization with limited membership"
      })
      {:ok, _} = Organizations.add_user_to_organization(organization.id, user.id, "viewer")

      # Create another user to attempt to add
      {:ok, new_member} = Accounts.create_user(%{
        email: "unauthorized_member@example.com",
        password: "password123",
        name: "Unauthorized Member"
      })

      # Prepare member addition params
      member_params = %{
        user_id: new_member.id,
        role: "viewer"
      }

      # Make the request
      conn = post(conn, ~p"/api/organizations/#{organization.id}/members", member_params)

      # Assert forbidden response
      assert %{"error" => "You do not have permission to add members"} = json_response(conn, 403)
    end
  end

  describe "remove_member" do
    test "admin can remove a member from the organization", %{conn: conn, user: user} do
      # Create an organization and add the current user as an admin
      {:ok, organization} = Organizations.create_organization(%{
        name: "Removable Members Org",
        description: "An organization for testing member removal"
      })
      {:ok, _} = Organizations.add_user_to_organization(organization.id, user.id, "admin")

      # Create another user to add and then remove
      {:ok, member_to_remove} = Accounts.create_user(%{
        email: "removable_member@example.com",
        password: "password123",
        name: "Removable Member"
      })
      {:ok, _} = Organizations.add_user_to_organization(organization.id, member_to_remove.id, "viewer")

      # Make the request
      conn = delete(conn, ~p"/api/organizations/#{organization.id}/members/#{member_to_remove.id}")

      # Assert response
      assert response(conn, 204)

      # Verify member was removed
      assert {:error, :not_found} = Organizations.get_user_role(organization.id, member_to_remove.id)
    end

    test "prevents non-admin users from removing members", %{conn: conn, user: user} do
      # Create an organization and add the current user as a viewer
      {:ok, organization} = Organizations.create_organization(%{
        name: "Restricted Removal Org",
        description: "An organization with limited member management"
      })
      {:ok, _} = Organizations.add_user_to_organization(organization.id, user.id, "viewer")

      # Create another user to attempt to remove
      {:ok, member_to_remove} = Accounts.create_user(%{
        email: "unauthorized_removal@example.com",
        password: "password123",
        name: "Unauthorized Removal Member"
      })
      {:ok, _} = Organizations.add_user_to_organization(organization.id, member_to_remove.id, "viewer")

      # Make the request
      conn = delete(conn, ~p"/api/organizations/#{organization.id}/members/#{member_to_remove.id}")

      # Assert forbidden response
      assert %{"error" => "You do not have permission to remove members"} = json_response(conn, 403)
    end
  end

  describe "update_member_role" do
    test "admin can update a member's role", %{conn: conn, user: user} do
      # Create an organization and add the current user as an admin
      {:ok, organization} = Organizations.create_organization(%{
        name: "Role Update Org",
        description: "An organization for testing role updates"
      })
      {:ok, _} = Organizations.add_user_to_organization(organization.id, user.id, "admin")

      # Create another user to update role
      {:ok, member_to_update} = Accounts.create_user(%{
        email: "role_update_member@example.com",
        password: "password123",
        name: "Role Update Member"
      })
      {:ok, _} = Organizations.add_user_to_organization(organization.id, member_to_update.id, "viewer")

      # Prepare role update params
      role_update_params = %{
        role: "scheduler"
      }

      # Make the request
      conn = put(conn, ~p"/api/organizations/#{organization.id}/members/#{member_to_update.id}/role", role_update_params)

      # Assert response
      assert response(conn, 204)

      # Verify member's role was updated
      assert {:ok, "scheduler"} = Organizations.get_user_role(organization.id, member_to_update.id)
    end

    test "prevents non-admin users from updating member roles", %{conn: conn, user: user} do
      # Create an organization and add the current user as a viewer
      {:ok, organization} = Organizations.create_organization(%{
        name: "Restricted Role Update Org",
        description: "An organization with limited role management"
      })
      {:ok, _} = Organizations.add_user_to_organization(organization.id, user.id, "viewer")

      # Create another user to attempt role update
      {:ok, member_to_update} = Accounts.create_user(%{
        email: "unauthorized_role_update@example.com",
        password: "password123",
        name: "Unauthorized Role Update Member"
      })
      {:ok, _} = Organizations.add_user_to_organization(organization.id, member_to_update.id, "viewer")

      # Prepare role update params
      role_update_params = %{
        role: "admin"
      }

      # Make the request
      conn = put(conn, ~p"/api/organizations/#{organization.id}/members/#{member_to_update.id}/role", role_update_params)

      # Assert forbidden response
      assert %{"error" => "You do not have permission to update member roles"} = json_response(conn, 403)
    end
  end
end
