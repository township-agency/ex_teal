defmodule ExTeal.Resource.AttributesTest do
  use ExUnit.Case
  alias ExTeal.Resource.Attributes

  defmodule DefaultResource do
    use ExTeal.Resource.Attributes

    alias ExTeal.Fields.{Number, Place, RichText, Text}
    alias ExTeal.Resource.Attributes

    def fields,
      do: [
        Text.make(:title),
        Number.make(:order),
        RichText.make(:body) |> Attributes.sanitize_as(:html5),
        Place.make(:address)
      ]
  end

  defmodule PanelResource do
    use ExTeal.Resource.Attributes

    alias ExTeal.Fields.{Number, Place, RichText, Text}
    alias ExTeal.Panel
    alias ExTeal.Resource.Attributes

    def fields,
      do: [
        Text.make(:title),
        Number.make(:order),
        RichText.make(:body) |> Attributes.sanitize_as(:html5),
        Panel.new("Address", [Place.make(:address)])
      ]
  end

  defmodule CustomResource do
    use ExTeal.Resource.Attributes

    def permitted_attributes(_conn, attrs, _) do
      Map.take(attrs, ~w(title))
    end
  end

  @address %{
    "address" => "1600 Pennsylvania Ave NW",
    "address_line_2" => "",
    "city" => "Washington",
    "state" => "DC",
    "zip" => "20500"
  }

  test "permitted attributes default" do
    attrs = %{
      "type" => "post",
      "title" => "a post",
      "category_id" => "1",
      "address" => @address
    }

    actual = DefaultResource.permitted_attributes(%Plug.Conn{}, attrs, :update)

    assert actual == %{
             "title" => "a post",
             "category_id" => "1",
             "address" => @address
           }
  end

  test "panels are ignored" do
    attrs = %{
      "type" => "post",
      "title" => "a post",
      "category_id" => "1",
      "address" => @address
    }

    actual = PanelResource.permitted_attributes(%Plug.Conn{}, attrs, :update)

    assert actual == %{
             "title" => "a post",
             "category_id" => "1",
             "address" => @address
           }
  end

  test "replaces an empty string with nil" do
    attrs = %{
      "title" => ""
    }

    actual = DefaultResource.permitted_attributes(%Plug.Conn{}, attrs, :update)

    assert actual == %{
             "title" => nil
           }
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

  test "automatically escapes fields" do
    attrs = %{
      "title" => "<a href=\"javascript:alert('XSS');\">text here</a>",
      "order" => "1",
      "body" => "<a href=\"https://google.com\">text here</a>"
    }

    params = DefaultResource.permitted_attributes(%Plug.Conn{}, attrs, :create)

    assert params == %{
             "title" => "text here",
             "order" => "1",
             "body" => "<a href=\"https://google.com\">text here</a>"
           }
  end

  test "sanitizes with HtmlSanitizeEx" do
    param = "<a href=\"javascript:alert('XSS');\">text here</a>"
    safe_link = "<a href=\"https://google.com\">Google</a>"

    assert Attributes.sanitize(false, param) == param
    assert Attributes.sanitize(:noscrub, param) == param
    assert Attributes.sanitize(:basic_html, param) == "<a>text here</a>"
    assert Attributes.sanitize(:basic_html, safe_link) == safe_link

    assert Attributes.sanitize(:html5, param) == "<a>text here</a>"
    assert Attributes.sanitize(:html5, safe_link) == safe_link

    assert Attributes.sanitize(:markdown_html, param) == "<a>text here</a>"
    assert Attributes.sanitize(:markdown_html, safe_link) == safe_link

    assert Attributes.sanitize(:strip_tags, param) == "text here"
    assert Attributes.sanitize(:strip_tags, safe_link) == "Google"
  end

  test "bypasses non-bitstring fields" do
    attrs = %{
      "file" => %{
        content_type: "image/jpeg",
        filename: "IMG_1240.jpg",
        path: "/tmp/plug-1564/multipart-1564173492-946871274981605-1"
      }
    }

    params = DefaultResource.permitted_attributes(%Plug.Conn{}, attrs, :create)

    assert attrs == params
  end
end
