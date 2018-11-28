defmodule ExTeal.Fields.RichTextTest do
  use ExUnit.Case
  alias ExTeal.Fields.RichText

  describe "make/1" do
    test "sets the field properties" do
      field = RichText.make(:description)
      assert field.attribute == "description"
      assert field.name == "Description"
    end
  end

  describe "make/2" do
    test "sets a custom name" do
      field = RichText.make(:description, "Project Description")
      assert field.attribute == "description"
      assert field.name == "Project Description"
    end
  end

  test "is sortable by default" do
    field = RichText.make(:description)
    assert field.sortable
  end

  test "has a component" do
    field = RichText.make(:description)
    assert field.component == "rich-text"
  end

  test "is not shown on the index" do
    field = RichText.make(:description)
    refute field.show_on_index
  end
end
