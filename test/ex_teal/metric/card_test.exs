defmodule ExTeal.Metric.CardTest do
  use TestExTeal.ConnCase

  alias ExTeal.Metric.Card

  defmodule PlainCard do
    use Card
  end

  defmodule FancyCard do
    use Card

    @impl true
    def uri, do: "fancy"

    @impl true
    def title, do: "Most Fancy"

    @impl true
    def width, do: "full"

    @impl true
    def only_on_index(_conn), do: true

    @impl true
    def only_on_detail(conn), do: conn.request_path == "foo"

    def options, do: %{foo: "bar"}
  end

  describe "uri/0" do
    test "sets a default" do
      assert PlainCard.uri() == "plain_card"
    end

    test "can be overriden" do
      assert FancyCard.uri() == "fancy"
    end
  end

  describe "title/0" do
    test "sets a default" do
      assert PlainCard.title() == "Plain card"
    end

    test "can be overriden" do
      assert FancyCard.title() == "Most Fancy"
    end
  end

  describe "width/0" do
    test "sets a default" do
      assert PlainCard.width() == "1/3"
    end

    test "can be overriden" do
      assert FancyCard.width() == "full"
    end
  end

  describe "only_on_index/1" do
    test "sets a default", %{conn: conn} do
      refute PlainCard.only_on_index(conn)
    end

    test "can be overriden", %{conn: conn} do
      assert FancyCard.only_on_index(conn)
    end
  end

  describe "only_on_detail/1" do
    test "sets a default", %{conn: conn} do
      refute PlainCard.only_on_detail(conn)
    end

    test "can be overriden", %{conn: conn} do
      refute FancyCard.only_on_detail(conn)
      assert FancyCard.only_on_detail(build_conn(:get, "foo"))
    end
  end
end
