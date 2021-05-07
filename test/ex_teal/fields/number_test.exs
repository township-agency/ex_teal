defmodule ExTeal.Fields.NumberTest do
  use ExUnit.Case
  alias ExTeal.Fields.Number

  describe "make/1" do
    test "sets the field properties" do
      field = Number.make(:password)
      assert field.attribute == "password"
      assert field.name == "Password"
    end
  end

  describe "make/2" do
    test "sets a custom name" do
      field = Number.make(:amount, "Amount")
      assert field.attribute == "amount"
      assert field.name == "Amount"
    end
  end

  test "has a component" do
    field = Number.make(:amount)
    assert field.component == "text-field"
  end

  test "has a field filter" do
    field = Number.make(:amount)
    assert field.filterable == ExTeal.FieldFilter.Number
  end

  test "is shown on edit" do
    field = Number.make(:amount)
    assert field.show_on_edit
  end

  test "is shown on the index" do
    field = Number.make(:password)
    assert field.show_on_index
  end

  test "is shown on detail" do
    field = Number.make(:password)
    assert field.show_on_detail
  end

  describe "with_options/2" do
    test "accepts a map and stores them as options" do
      field = Number.make(:price)
      assert field.options == %{}
    end
  end
end
