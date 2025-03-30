defmodule FarmshiftBackendWeb.Mobile.AuthJSON do
  @doc """
  Renders user data with token for mobile registration response.
  """
  def register(%{user: user, token: token}) do
    %{
      status: "success",
      data: %{
        user: user_json(user),
        token: token,
        token_type: "Bearer"
      }
    }
  end

  @doc """
  Renders user data with token for mobile login response.
  """
  def login(%{user: user, token: token, device_info: device_info}) do
    %{
      status: "success",
      data: %{
        user: user_json(user),
        token: token,
        token_type: "Bearer",
        # Include device info in the response if it was provided
        device_info: device_info
      }
    }
  end

  @doc """
  Renders the current mobile user data.
  """
  def user(%{user: user}) do
    %{
      status: "success",
      data: %{
        user: user_json(user)
      }
    }
  end

  @doc """
  Renders a mobile logout success message.
  """
  def logout(%{message: message}) do
    %{
      status: "success",
      message: message
    }
  end

  @doc """
  Renders a refreshed token.
  """
  def token(%{token: token}) do
    %{
      status: "success",
      data: %{
        token: token,
        token_type: "Bearer"
      }
    }
  end

  # Private helper for formatting user data
  defp user_json(user) do
    %{
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      inserted_at: user.inserted_at
    }
  end
end
