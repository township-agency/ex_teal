defmodule ExTeal.Fields.DateTest do
  use ExUnit.Case
  alias ExTeal.Fields.Date

  describe "make/1" do
    test "sets the field properties" do
      field = Date.make(:published_at)
      assert field.attribute == "published_at"
      assert field.name == "Published at"
    end
  end

  describe "make/2" do
    test "sets a custom name" do
      field = Date.make(:published_at, "Published On")
      assert field.attribute == "published_at"
      assert field.name == "Published On"
    end
  end

  test "is sortable by default" do
    field = Date.make(:published_at)
    assert field.sortable
  end

  test "has a component" do
    field = Date.make(:published_at)
    assert field.component == "date"
  end

  describe "format/2" do
    test "can set the format for the index and detail pages" do
      field = Date.make(:published_at)
      assert field.options == %{}

      field = Date.format(field, :short)
      assert field.options == %{format: "date_short"}
    end
  end
end
