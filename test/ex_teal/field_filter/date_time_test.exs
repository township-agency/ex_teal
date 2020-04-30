defmodule ExTeal.FieldFilter.DateTimeTest do
  use TestExTeal.ConnCase

  alias ExTeal.FieldFilter.DateTime, as: DT
  alias TestExTeal.{Post, PostResource}

  test "interface_type is date-time" do
    assert DT.interface_type() == "date-time"
  end

  describe "filter/3" do
    test "= naive comparison converts the dt" do
      dt = ~N[2000-01-01 23:00:07]
      comparison = "2000-01-01T18:00:07-05:00"
      %Post{id: id} = insert(:post, published_at: dt)
      [result] = find_post("=", :published_at, comparison)
      assert result.id == id
    end

    test "= dt comparison converts the dt" do
      {:ok, dt, _} = DateTime.from_iso8601("2000-01-01T23:00:00Z")
      comparison = "2000-01-01T18:00:00-05:00"
      %Post{id: id} = insert(:post, deleted_at: dt)
      [result] = find_post("=", :deleted_at, comparison)
      assert result.id == id
    end

    defp find_post(op, field, operand) do
      Post
      |> DT.filter(%{"operator" => op, "operand" => operand}, field, PostResource)
      |> Repo.all()
    end
  end

  describe "value_cast_to_field_type/3" do
    test "uses the resource to determine the type of a field and cast the value" do
      dt = ~N[2000-01-01 23:00:07]
      value = "2000-01-01T18:00:07-05:00"

      result = DT.value_cast_to_field_type(PostResource, :published_at, value)
      assert result == dt
    end
  end
end
