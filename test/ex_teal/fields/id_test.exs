defmodule ExTeal.Fields.IDTest do
  use ExUnit.Case
  alias ExTeal.Fields.ID

  describe "make/1" do
    test "sets the field properties" do
      field = ID.make(:id)
      assert field.attribute == "id"
      assert field.name == "Id"
    end
  end

  describe "make/2" do
    test "sets a custom name" do
      field = ID.make(:id, "Primary ID")
      assert field.attribute == "id"
      assert field.name == "Primary ID"
    end
  end

  test "is sortable by default" do
    field = ID.make(:id)
    assert field.sortable
  end

  test "has a component" do
    field = ID.make(:id)
    assert field.component == "text-field"
  end
end
