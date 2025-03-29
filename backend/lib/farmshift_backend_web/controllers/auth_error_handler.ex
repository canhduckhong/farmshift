defmodule FarmshiftBackendWeb.AuthErrorHandler do
  @moduledoc """
  Handles errors that occur during Guardian authentication.
  """
  
  import Plug.Conn

  @doc """
  Callback invoked by Guardian when authentication fails.
  """
  def auth_error(conn, {type, _reason}, _opts) do
    body = Jason.encode!(%{
      status: "error",
      message: error_message(type)
    })

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status_code(type), body)
  end

  # Helper to return appropriate error messages
  defp error_message(:invalid_token), do: "Invalid token"
  defp error_message(:unauthenticated), do: "Not authenticated"
  defp error_message(:unauthorized), do: "Not authorized to access this resource"
  defp error_message(_), do: "Authentication error"

  # Helper to return appropriate status codes
  defp status_code(:invalid_token), do: 401
  defp status_code(:unauthenticated), do: 401
  defp status_code(:unauthorized), do: 403
  defp status_code(_), do: 401
end
