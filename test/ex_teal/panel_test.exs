defmodule ExTeal.PanelTest do
  use ExUnit.Case

  alias ExTeal.Fields.Text
  alias ExTeal.Panel

  defmodule SimpleResource do
    use ExTeal.Resource

    def title, do: "Posts"

    def fields,
      do: [
        Text.make(:name),
        Text.make(:body, "Content")
      ]
  end

  describe "new/2" do
    test "returns a panel struct" do
      default = Panel.new("Content", [Text.make(:name)])

      assert default == %Panel{
               name: "Content",
               key: :content,
               fields: [
                 :name |> Text.make() |> Map.put(:panel, :content)
               ]
             }
    end
  end

  describe "new/3" do
    test "passing a set of options to new" do
      default = Panel.new("Content", [Text.make(:name)], %{helper_text: "Some text"})

      assert default == %Panel{
               name: "Content",
               key: :content,
               fields: [
                 :name |> Text.make() |> Map.put(:panel, :content)
               ],
               options: %{helper_text: "Some text"}
             }
    end

    test "passing a set of options with a apply_to_all key" do
      applied = Panel.new("Content", [Text.make(:name)], %{apply_to_all: %{show_on_new: false}})

      assert applied == %Panel{
               name: "Content",
               key: :content,
               fields: [
                 :name |> Text.make() |> Map.put(:panel, :content) |> Map.put(:show_on_new, false)
               ],
               options: %{apply_to_all: %{show_on_new: false}}
             }
    end
  end

  describe "gather_panels/1" do
    test "given a resource without panels, returns a single panel with the resource name" do
      panels = Panel.gather_panels(SimpleResource)
      assert panels == [%Panel{key: :"post details", name: "Post Details"}]
    end
  end

  test "helper_text/2 passes a string to the options" do
    default = Panel.new("Content", [])
    result = Panel.helper_text(default, "Some text")
    assert result.options == %{helper_text: "Some text"}
  end

  test "limit/2 passes the limit to the options" do
    default = Panel.new("Content", [])
    result = Panel.limit(default, 1)
    assert result.options == %{limit: 1}
  end
end
