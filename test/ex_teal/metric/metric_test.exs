defmodule ExTeal.Metric.MetricTest do
  use TestExTeal.ConnCase

  alias ExTeal.Metric

  defmodule PlainMetric do
    use Metric
  end

  defmodule FancyMetric do
    use Metric

    @impl true
    def uri, do: "fancy"

    @impl true
    def title, do: "Most Fancy"

    @impl true
    def width, do: "full"

    @impl true
    def only_on_index(_conn), do: true

    @impl true
    def only_on_detail(conn), do: conn.request_path == "/foo"

    @impl true
    def options, do: %{foo: "bar"}
  end

  describe "uri/0" do
    test "sets a default" do
      assert PlainMetric.uri() == "plain_metric"
    end

    test "can be overriden" do
      assert FancyMetric.uri() == "fancy"
    end
  end

  describe "title/0" do
    test "sets a default" do
      assert PlainMetric.title() == "Plain metric"
    end

    test "can be overriden" do
      assert FancyMetric.title() == "Most Fancy"
    end
  end

  describe "width/0" do
    test "sets a default" do
      assert PlainMetric.width() == "1/3"
    end

    test "can be overriden" do
      assert FancyMetric.width() == "full"
    end
  end

  describe "only_on_index/1" do
    test "sets a default", %{conn: conn} do
      refute PlainMetric.only_on_index(conn)
    end

    test "can be overriden", %{conn: conn} do
      assert FancyMetric.only_on_index(conn)
    end
  end

  describe "only_on_detail/1" do
    test "sets a default", %{conn: conn} do
      refute PlainMetric.only_on_detail(conn)
    end

    test "can be overriden", %{conn: conn} do
      refute FancyMetric.only_on_detail(conn)
      assert FancyMetric.only_on_detail(build_conn(:get, "/foo"))
    end
  end
end
