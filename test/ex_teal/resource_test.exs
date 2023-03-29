defmodule ExTeal.ResourceTest do
  use ExUnit.Case

  alias ExTeal.Resource

  defmodule ExTealTest.PostResource do
    use ExTeal.Resource

    def hide_from_nav, do: true
  end

  defmodule ExTealTest.GroupResource do
    use ExTeal.Resource

    def nav_group(_), do: "Admin"

    def singular_title, do: "Foo"
  end

  defmodule ExTealTest.TestResource do
    use ExTeal.Resource
  end

  describe "hide_from_nav/0" do
    alias ExTealTest.{PostResource, TestResource}

    test "can be overridden" do
      assert PostResource.hide_from_nav()
      refute TestResource.hide_from_nav()
    end
  end

  describe "group_resource/1" do
    test "can be overriden" do
      refute ExTealTest.TestResource.nav_group(%{})
      assert ExTealTest.GroupResource.nav_group(%{}) == "Admin"
    end
  end

  describe "map_to_json/1" do
    test "returns serialized versions" do
      assert Resource.map_to_json([ExTealTest.PostResource, ExTealTest.GroupResource], %{}) == [
               %{
                 title: "Posts",
                 singular: "Post",
                 uri: "posts",
                 group: nil,
                 hidden: true,
                 searchable: false,
                 skip_sanitize: false,
                 can_create_any: true,
                 can_delete_any: true,
                 can_update_any: true,
                 can_view_any: true,
                 default_filters: nil
               },
               %{
                 title: "Groups",
                 singular: "Foo",
                 uri: "groups",
                 group: "Admin",
                 hidden: false,
                 searchable: false,
                 skip_sanitize: false,
                 can_create_any: true,
                 can_delete_any: true,
                 can_update_any: true,
                 can_view_any: true,
                 default_filters: nil
               }
             ]
    end
  end
end
