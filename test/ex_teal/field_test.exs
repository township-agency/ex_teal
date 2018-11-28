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
end
