defmodule ExTeal.FieldFilter.TextTest do
  use TestExTeal.ConnCase

  alias ExTeal.FieldFilter.Text
  alias TestExTeal.Post

  test "interface_type is text" do
    assert Text.interface_type() == "text"
  end

  describe "filter/3" do
    test "=" do
      %Post{id: id} = insert(:post, name: "Foo")
      [result] = find_post("=", "Foo")
      assert result.id == id
    end

    test "!=" do
      %Post{id: _id} = insert(:post, name: "Foo")
      %Post{id: id_b} = insert(:post, name: "Bar")
      [result] = find_post("!=", "Foo")
      assert result.id == id_b
    end

    test "contains" do
      %Post{id: id} = insert(:post, name: "Foo")
      %Post{id: id_b} = insert(:post, name: "Bar")
      %Post{id: id_c} = insert(:post, name: "Baz")
      [result, result2] = find_post("contains", "a")
      refute id in [result.id, result2.id]
      assert id_b in [result.id, result2.id]
      assert id_c in [result.id, result2.id]
    end

    test "does not contain" do
      %Post{id: id} = insert(:post, name: "Foo")
      insert(:post, name: "Bar")
      insert(:post, name: "Baz")
      [result] = find_post("does not contains", "a")
      assert result.id == id
    end

    test "is empty" do
      %Post{id: id} = insert(:post, name: nil)
      insert(:post, name: "Bar")
      insert(:post, name: "Baz")
      [result] = find_post("is empty")
      assert result.id == id
    end

    test "not empty" do
      %Post{id: id} = insert(:post, name: "Foo")
      insert(:post, name: nil)
      [result] = find_post("not empty")
      assert result.id == id
    end

    defp find_post(op) do
      Post
      |> Text.filter(%{"operator" => op}, :name)
      |> Repo.all()
    end

    defp find_post(op, operand) do
      Post
      |> Text.filter(%{"operator" => op, "operand" => operand}, :name)
      |> Repo.all()
    end
  end
end
