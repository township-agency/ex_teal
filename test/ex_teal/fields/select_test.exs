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

  describe "with_options/2" do
    test "accepts a map and stores them as options" do
      field = Select.make(:size)
      assert field.options == %{}

      options = %{
        "S" => "Small",
        "M" => "Medium",
        "L" => "Large"
      }

      field = Select.with_options(field, options)
      assert field.options == options
      assert field.private_options.display_using_labels == false
    end

    test "accepts a function and stores them as options" do
      field = Select.make(:size)
      assert field.options == %{}

      options = %{
        "S" => "Small",
        "M" => "Medium",
        "L" => "Large"
      }

      field =
        Select.with_options(field, fn ->
          options
        end)

      assert field.options == options
      assert field.private_options.display_using_labels == false
    end
  end

  describe "display_using_labels/1" do
    test "passes the option to the struct" do
      field = Select.make(:size)
      assert field.options == %{}

      options = %{
        "S" => "Small",
        "M" => "Medium",
        "L" => "Large"
      }

      field =
        field
        |> Select.with_options(fn ->
          options
        end)
        |> Select.display_using_labels()

      assert field.options == options
      assert field.private_options.display_using_labels == true
    end
  end

  describe "value_for/2" do
    test "returns the default value" do
      field = Select.make(:size)
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

      field =
        field
        |> Select.with_options(options)
        |> Select.display_using_labels()

      model = %{size: "S"}
      assert Select.value_for(field, model, :edit) == "S"
    end

    test "returns the labeled value for index" do
      field = Select.make(:size)

      options = %{
        "S" => "Small",
        "M" => "Medium",
        "L" => "Large"
      }

      field =
        field
        |> Select.with_options(options)
        |> Select.display_using_labels()

      model = %{size: "S"}
      assert Select.value_for(field, model, :index) == "Small"
    end

    test "returns the labeled value for show" do
      field = Select.make(:size)

      options = %{
        "S" => "Small",
        "M" => "Medium",
        "L" => "Large"
      }

      field =
        field
        |> Select.with_options(options)
        |> Select.display_using_labels()

      model = %{size: "S"}
      assert Select.value_for(field, model, :show) == "Small"
    end
  end
end
