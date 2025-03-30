defmodule FarmshiftBackend.Auth.Guardian do
  @moduledoc """
  Implementation module for Guardian authentication.
  This handles JWT token generation, verification, and resource fetching.
  """
  use Guardian, otp_app: :farmshift_backend

  alias FarmshiftBackend.Accounts

  @doc """
  Used by Guardian to fetch the resource for a token.
  Converts the user ID to a string for token generation.
  """
  def subject_for_token(user, _claims) do
    # Ensure the user ID is converted to a string
    {:ok, to_string(user.id)}
  end

  @doc """
  Used by Guardian to build a resource from a token claim.
  Handles UUID-based user lookup.
  """
  def resource_from_claims(claims) do
    # Extract the user ID from claims
    id = claims["sub"]

    # Validate and fetch the user
    case Ecto.UUID.cast(id) do
      {:ok, uuid} ->
        resource = Accounts.get_user!(uuid)
        {:ok, resource}
      :error ->
        {:error, :invalid_token}
    end
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end
end
