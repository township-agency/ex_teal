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

  describe "with_options/2" do
    test "accepts a map and stores them as options" do
      field = Date.make(:published_at)
      assert field.options == %{}

      options = %{
        "format" => "MMM. D, YYYY"
      }

      field = Date.with_options(field, options)
      assert field.options == options
    end
  end
end
