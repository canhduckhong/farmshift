defmodule FarmshiftBackendWeb.FallbackController do
  @moduledoc """
  Handles fallback errors for controllers.
  Provides consistent error responses for various error types.
  """
  use FarmshiftBackendWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: FarmshiftBackendWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: FarmshiftBackendWeb.ErrorJSON)
    |> render(:not_found)
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(json: FarmshiftBackendWeb.ErrorJSON)
    |> render(:unauthorized)
  end
end

defmodule FarmshiftBackendWeb.ChangesetJSON do
  @doc """
  Renders changeset errors.
  """
  def error(%{changeset: changeset}) do
    %{
      errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    }
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end

defmodule FarmshiftBackendWeb.ErrorJSON do
  @doc """
  Renders standard error responses.
  """
  def not_found(_) do
    %{error: "Not Found"}
  end

  def unauthorized(_) do
    %{error: "Unauthorized"}
  end
end
