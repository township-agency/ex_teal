defmodule ExTeal.Resource.AttributesTest do
  use ExUnit.Case
  alias ExTeal.Resource.Attributes

  defmodule DefaultResource do
    use ExTeal.Resource.Attributes
  end

  defmodule CustomResource do
    use ExTeal.Resource.Attributes

    def permitted_attributes(_conn, attrs, _) do
      Map.take(attrs, ~w(title))
    end
  end

  test "permitted attributes default" do
    attrs = %{
      "type" => "post",
      "title" => "a post",
      "category_id" => "1"
    }

    actual = DefaultResource.permitted_attributes(%Plug.Conn{}, attrs, :update)
    assert actual == attrs
  end

  test "permitted attributes custom" do
    attrs = %{
      "type" => "post",
      "title" => "a post",
      "category_id" => "1"
    }

    actual = CustomResource.permitted_attributes(%Plug.Conn{}, attrs, :update)
    assert actual == %{"title" => "a post"}
  end

  test "formatting attributes from json" do
    params = %{
      "title" => "a post"
    }

    merged = %{
      "title" => "a post"
    }

    actual = Attributes.from_params(params)
    assert actual == merged
  end
end
