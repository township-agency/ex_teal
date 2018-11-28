defmodule ExTeal.Resource.QueryTest do
  use TestExTeal.ConnCase
  alias ExTeal.Resource.Query
  alias TestExTeal.Post

  defmodule FooBar do
    defstruct [:id]
  end

  describe "default_display_title/1" do
    test "returns a title value" do
      assert Query.default_display_title(%Post{name: "Foo"}) == "Foo"
    end

    test "returns a fallback" do
      assert Query.default_display_title(%Post{id: 1}) == "Post: 1"
    end

    test "works for a generic struct" do
      assert Query.default_display_title(%FooBar{id: 1}) == "FooBar: 1"
    end
  end
end
