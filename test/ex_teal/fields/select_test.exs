defmodule ExTeal.Fields.SelectTest do
  use ExUnit.Case

  alias ExTeal.Fields.Select

  describe "make/1" do
    test "sets the field properties" do
      field = Select.make(:size)
      assert field.attribute == "size"
      assert field.name == "Size"
    end
  end

  describe "make/2" do
    test "sets a custom name" do
      field = Select.make(:size, "Shirt Size")
      assert field.attribute == "size"
      assert field.name == "Shirt Size"
    end
  end

  test "is sortable by default" do
    field = Select.make(:size)
    assert field.sortable
  end

  test "has a component" do
    field = Select.make(:size)
    assert field.component == "select"
  end

  describe "value_for/2" do
    test "returns the default value" do
      field = Select.make(:size) |> Select.options(~w(S M L))
      model = %{size: "S"}
      assert Select.value_for(field, model, :show) == "S"
    end

    test "returns the default value for edit" do
      field = Select.make(:size)

      options = %{
        "S" => "Small",
        "M" => "Medium",
        "L" => "Large"
      }

      field = Select.options(field, options)

      model = %{size: "S"}
      assert Select.value_for(field, model, :edit) == "S"
    end

    test "returns the labeled value for index" do
      opts = %{"1" => "One", "2" => "Two"}
      field = Select.make(:size) |> Select.options(opts)

      model = %{size: "One"}
      assert Select.value_for(field, model, :index) == "1"
    end

    test "returns the labeled value for show" do
      opts = %{"1" => "One", "2" => "Two"}
      field = Select.make(:size) |> Select.options(opts)

      model = %{size: "One"}
      assert Select.value_for(field, model, :show) == "1"
    end

    test "returns the value for show with option groups" do
      opts = [
        {"foo", ~w(bar baz)},
        {"qux", ~w(qux quz)}
      ]

      field = Select.make(:size) |> Select.options(opts)

      model = %{size: "bar"}
      assert Select.value_for(field, model, :show) == "bar"
    end
  end

  describe "transform_options/1" do
    test "with a binary list" do
      assert Select.transform_options(~w(foo bar)) == [
               %{disabled: false, value: "foo", key: "foo"},
               %{disabled: false, value: "bar", key: "bar"}
             ]
    end

    test "with a keyword list" do
      assert Select.transform_options(Foo: "foo", Bar: "bar") == [
               %{disabled: false, value: "foo", key: :Foo},
               %{disabled: false, value: "bar", key: :Bar}
             ]

      assert Select.transform_options([
               [key: "Foo", value: "foo"],
               [key: "Bar", value: "bar", disabled: true]
             ]) == [
               %{disabled: false, value: "foo", key: "Foo"},
               %{disabled: true, value: "bar", key: "Bar"}
             ]
    end

    test "with a map" do
      assert Select.transform_options(%{"1" => "One", "2" => "Two"}) == [
               %{disabled: false, value: "One", key: "1"},
               %{disabled: false, value: "Two", key: "2"}
             ]
    end

    test "with optgroups" do
      assert Select.transform_options([
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

      assert Select.transform_options(%{
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

  test "can be searchable" do
    field = Select.make(:foo) |> Select.searchable()
    assert field.options.searchable
  end
end
