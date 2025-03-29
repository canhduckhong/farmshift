defmodule FarmshiftBackendWeb.ErrorJSON do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on JSON requests.
  Handles formatting of error responses in a consistent manner.
  """

  # Authentication error responses
  def render("401.json", %{message: message}) do
    %{
      status: "error",
      code: 401,
      message: message
    }
  end

  def render("403.json", _assigns) do
    %{
      status: "error",
      code: 403,
      message: "Forbidden"
    }
  end

  # Validation error responses
  def render("422.json", %{changeset: changeset}) do
    %{
      status: "error",
      code: 422,
      message: "Validation failed",
      errors: translate_errors(changeset)
    }
  end

  # Default error response
  def render(template, _assigns) do
    %{
      status: "error",
      code: status_code_from_template(template),
      message: Phoenix.Controller.status_message_from_template(template)
    }
  end

  # Extracts status code from template name
  defp status_code_from_template(template) do
    template
    |> String.split(".")
    |> List.first()
    |> String.to_integer()
  rescue
    _ -> 500
  end

  # Translates changeset errors into a more user-friendly format
  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts
        |> Keyword.get(String.to_existing_atom(key), key)
        |> to_string()
      end)
    end)
  end
end
