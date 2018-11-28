defmodule ExTeal.Resource.FieldsTest do
  use ExUnit.Case
  alias ExTeal.Fields.Text
  alias ExTeal.Resource.Fields

  defmodule SimplePostResource do
    use ExTeal.Resource
    alias ExTeal.Fields.Text

    def fields,
      do: [
        Text.make(:name),
        Text.make(:description)
      ]
  end

  defmodule PanelPostResource do
    use ExTeal.Resource
    alias ExTeal.Fields.Text
    alias ExTeal.Panel

    def title, do: "Posts"

    def fields,
      do: [
        Text.make(:name),
        Panel.new("Content", [
          Text.make(:description)
        ])
      ]
  end

  describe "all_fields/1" do
    test "returns all fields for a simple resource" do
      fields = Fields.all_fields(SimplePostResource)
      assert fields == SimplePostResource.fields()
    end

    test "a resource with a panel returns the nested fields" do
      fields = Fields.all_fields(PanelPostResource)

      assert fields == [
               Text.make(:name),
               :description |> Text.make() |> Map.put(:panel, :content)
             ]
    end
  end
end
