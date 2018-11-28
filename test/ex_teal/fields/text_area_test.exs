defmodule ExTeal.Fields.TextAreaTest do
  use ExUnit.Case
  alias ExTeal.Fields.TextArea

  describe "make/1" do
    test "sets the field properties" do
      field = TextArea.make(:published)
      assert field.attribute == "published"
      assert field.name == "Published"
    end
  end

  describe "make/2" do
    test "sets a custom name" do
      field = TextArea.make(:published, "Primary Published")
      assert field.attribute == "published"
      assert field.name == "Primary Published"
    end
  end

  test "is sortable by default" do
    field = TextArea.make(:published)
    assert field.sortable
  end

  test "has a component" do
    field = TextArea.make(:published)
    assert field.component == "text-area"
  end

  test "is not shown on the index" do
    field = TextArea.make(:published)
    refute field.show_on_index
  end
end
