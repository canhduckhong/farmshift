defmodule FarmshiftBackendWeb.AuthJSON do
  @doc """
  Renders user data with token for registration response.
  """
  def register(%{user: user, token: token}) do
    %{
      status: "success",
      data: %{
        user: user_json(user),
        token: token
      }
    }
  end

  @doc """
  Renders user data with token for login response.
  """
  def login(%{user: user, token: token}) do
    %{
      status: "success",
      data: %{
        user: user_json(user),
        token: token
      }
    }
  end

  @doc """
  Renders the current user data.
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
  Renders a logout success message.
  """
  def logout(%{message: message}) do
    %{
      status: "success",
      message: message
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
