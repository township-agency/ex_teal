defmodule ExTeal.FieldTest do
  use ExUnit.Case
  alias ExTeal.Field

  describe "field_name/2" do
    test "returns the name by default" do
      assert Field.field_name(:created_at, nil) == "Created at"
    end

    test "returns the label if given in string form" do
      assert Field.field_name(:created_at, "Foo") == "Foo"
    end
  end

  describe "help_text/2" do
    test "adds the text to the options" do
      field = Field.help_text(%Field{}, "Foo Bar")
      assert field.options.help_text == "Foo Bar"
    end
  end
end
