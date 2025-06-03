defmodule EctoappWeb.ErrorJSONTest do
  use EctoappWeb.ConnCase, async: true

  test "renders 404" do
    assert EctoappWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert EctoappWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
