defmodule ExTeal.Fields.ToggleTest do
  use ExUnit.Case
  alias ExTeal.Fields.Toggle

  describe "make/1" do
    test "sets the field properties" do
      field = Toggle.make(:published)
      assert field.attribute == "published"
      assert field.name == "Published"
    end
  end

  describe "make/2" do
    test "sets a custom name" do
      field = Toggle.make(:published, "Primary Published")
      assert field.attribute == "published"
      assert field.name == "Primary Published"
    end
  end

  test "is sortable by default" do
    field = Toggle.make(:published)
    assert field.sortable
  end

  test "has a component" do
    field = Toggle.make(:published)
    assert field.component == "toggle"
  end

  test "true_value/2 sets a label" do
    field = Toggle.make(:open)
    assert field.options == %{}

    true_value = "Come in, we're open"
    field = Toggle.make(:open) |> Toggle.true_value(true_value)
    assert field.options == %{:true_value => true_value}
  end

  test "false_value/2 sets a label" do
    field = Toggle.make(:open)
    assert field.options == %{}

    false_value = "Sorry, we're closed"
    field = Toggle.make(:open) |> Toggle.false_value(false_value)
    assert field.options == %{:false_value => false_value}
  end

  test "chaining true_value/2 and false_value/2 preserves both labels" do
    field = Toggle.make(:open)
    assert field.options == %{}

    true_value = "Come in, we're open"
    false_value = "Sorry, we're closed"
    field = Toggle.make(:open) |> Toggle.true_value(true_value) |> Toggle.false_value(false_value)

    assert field.options == %{:true_value => true_value, :false_value => false_value}
  end
end
