defmodule FarmshiftBackendWeb.ErrorJSONTest do
  use ExUnit.Case, async: true

  test "renders 404" do
    assert FarmshiftBackendWeb.ErrorJSON.render("404.json", %{}) == %{
      status: "error",
      code: 404,
      message: "Not Found"
    }
  end

  test "renders 500" do
    assert FarmshiftBackendWeb.ErrorJSON.render("500.json", %{}) == %{
      status: "error", 
      code: 500,
      message: "Internal Server Error"
    }
  end
end
