defmodule ExTeal.Fields.BooleanTest do
  use ExUnit.Case
  alias ExTeal.Fields.Boolean

  describe "make/1" do
    test "sets the field properties" do
      field = Boolean.make(:published)
      assert field.attribute == "published"
      assert field.name == "Published"
    end
  end

  describe "make/2" do
    test "sets a custom name" do
      field = Boolean.make(:published, "Primary Published")
      assert field.attribute == "published"
      assert field.name == "Primary Published"
    end
  end

  test "is sortable by default" do
    field = Boolean.make(:published)
    assert field.sortable
  end

  test "has a component" do
    field = Boolean.make(:published)
    assert field.component == "boolean"
  end
end
