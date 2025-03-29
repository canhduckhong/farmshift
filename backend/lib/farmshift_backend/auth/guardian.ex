defmodule FarmshiftBackend.Auth.Guardian do
  @moduledoc """
  Implementation module for Guardian authentication.
  This handles JWT token generation, verification, and resource fetching.
  """
  use Guardian, otp_app: :farmshift_backend

  alias FarmshiftBackend.Accounts

  @doc """
  Used by Guardian to fetch the resource for a token.
  """
  def subject_for_token(user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  @doc """
  Used by Guardian to build a resource from a token claim.
  """
  def resource_from_claims(claims) do
    id = claims["sub"]
    resource = Accounts.get_user!(id)
    {:ok, resource}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end
end
