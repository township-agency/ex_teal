defmodule ExTeal.ResourceTest do
  use ExUnit.Case

  alias ExTeal.Resource

  defmodule ExTealTest.PostResource do
    use ExTeal.Resource

    def hide_from_nav, do: true
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

  describe "map_to_json/1" do
    test "returns serialized versions" do
      assert Resource.map_to_json([ExTealTest.PostResource]) == [
               %{
                 title: "Posts",
                 singular: "Post",
                 uri: "posts",
                 hidden: true,
                 searchable: false
               }
             ]
    end
  end
end
