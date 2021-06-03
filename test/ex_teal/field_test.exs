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

  describe "filter_as/2" do
    test "a field can have it's filterable type replaced" do
      field = %Field{filterable: ExTeal.FieldFilter.Date}
      result = Field.filter_as(field, ExTeal.FieldFilter.Text)
      assert result.filterable == ExTeal.FieldFilter.Text
    end
  end

  describe "transform_options/1" do
    test "with a binary list" do
      assert Field.transform_options(~w(foo bar)) == [
               %{disabled: false, value: "foo", key: "foo"},
               %{disabled: false, value: "bar", key: "bar"}
             ]
    end

    test "with a keyword list" do
      assert Field.transform_options(Foo: "foo", Bar: "bar") == [
               %{disabled: false, value: "foo", key: :Foo},
               %{disabled: false, value: "bar", key: :Bar}
             ]

      assert Field.transform_options([
               [key: "Foo", value: "foo"],
               [key: "Bar", value: "bar", disabled: true]
             ]) == [
               %{disabled: false, value: "foo", key: "Foo"},
               %{disabled: true, value: "bar", key: "Bar"}
             ]
    end

    test "with a map" do
      assert Field.transform_options(%{"1" => "One", "2" => "Two"}) == [
               %{disabled: false, value: "One", key: "1"},
               %{disabled: false, value: "Two", key: "2"}
             ]
    end

    test "with optgroups" do
      assert Field.transform_options([
               {"foo", ~w(bar baz)},
               {"qux", ~w(qux quz)}
             ]) == [
               %{
                 group: "foo",
                 options: [
                   %{disabled: false, value: "bar", key: "bar"},
                   %{disabled: false, value: "baz", key: "baz"}
                 ]
               },
               %{
                 group: "qux",
                 options: [
                   %{disabled: false, value: "qux", key: "qux"},
                   %{disabled: false, value: "quz", key: "quz"}
                 ]
               }
             ]

      assert Field.transform_options(%{
               "foo" => %{"1" => "One", "2" => "Two"},
               "qux" => ~w(qux quz)
             }) == [
               %{
                 group: "foo",
                 options: [
                   %{disabled: false, value: "One", key: "1"},
                   %{disabled: false, value: "Two", key: "2"}
                 ]
               },
               %{
                 group: "qux",
                 options: [
                   %{disabled: false, value: "qux", key: "qux"},
                   %{disabled: false, value: "quz", key: "quz"}
                 ]
               }
             ]
    end
  end
end
