defmodule ExTeal.FieldFilter.SelectTest do
  use TestExTeal.ConnCase

  alias ExTeal.FieldFilter.Select
  alias TestExTeal.{Post, PostResource}

  test "interface_type is text" do
    assert Select.interface_type() == "text"
  end

  describe "filter/3" do
    test "matches using the key to find the value" do
      %Post{id: id} = insert(:post, author: "foo")
      [result] = find_post("foo")
      assert result.id == id
    end

    test "matches using the value" do
      %Post{id: id} = insert(:post, contributor: "foo")
      [result] = find_post("foo", :contributor)
      assert result.id == id
    end

    defp find_post(op, key \\ :author) do
      field = Enum.find(PostResource.fields(), &(&1.field == key))

      Post
      |> Select.filter(%{"operator" => op}, field, PostResource)
      |> Repo.all()
    end
  end
end
