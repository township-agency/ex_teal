defmodule ExTeal.NavigationTest do
  use TestExTeal.FeatureCase, async: true
  @moduletag :feature

  hound_session()

  test "can see the resources in the side nav" do
    navigate_to("http://localhost:4001/teal")

    sidebar_text =
      :id
      |> find_element("sidebar")
      |> visible_text()

    assert String.contains?(sidebar_text, "Users")
    assert String.contains?(sidebar_text, "Posts")
  end
end
