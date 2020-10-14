defmodule ExTeal.Metric.ValueTest do
  use TestExTeal.ConnCase
  alias ExTeal.Metric.{Request, Result}
  alias TestExTeal.{Order, User}

  defmodule TestExTeal.NewUserMetric do
    use ExTeal.Metric.Value

    @impl true
    def calculate(request) do
      count(request, User)
    end

    @impl true
    def uri, do: "new-user"

    @impl true
    def title, do: "New Users"
  end

  defmodule TestExTeal.OrderAverageMetric do
    use ExTeal.Metric.Value
    @impl true
    def calculate(request), do: average(request, Order, :grand_total)

    @impl true
    def prefix, do: "$"

    @impl true
    def suffix, do: "Total"

    @impl true
    def format, do: "0,0"
  end

  setup context do
    {:ok, request: request_for_between(Map.get(context, :start, 10), Map.get(context, :end, 0))}
  end

  describe "count/2" do
    test "returns a value result", %{request: request} do
      result = TestExTeal.NewUserMetric.count(request, User)
      assert result.current == 0
      assert result.previous == 0
    end
  end

  describe "uri/0" do
    test "defaults to Teal Naming of the module" do
      assert TestExTeal.OrderAverageMetric.uri() == "order_average_metric"
    end

    test "can be overriden" do
      assert TestExTeal.NewUserMetric.uri() == "new-user"
    end
  end

  describe "prefix/0" do
    test "has a default" do
      assert TestExTeal.NewUserMetric.prefix() == nil
    end

    test "can be overriden" do
      assert TestExTeal.OrderAverageMetric.prefix() == "$"
    end
  end

  describe "suffix/0" do
    test "defaults to nil" do
      assert TestExTeal.NewUserMetric.suffix() == nil
    end

    test "can be overriden" do
      assert TestExTeal.OrderAverageMetric.suffix() == "Total"
    end
  end

  describe "format/0" do
    test "defaults to nil" do
      assert TestExTeal.NewUserMetric.format() == "(0[.]00a)"
    end

    test "can be overriden" do
      assert TestExTeal.OrderAverageMetric.format() == "0,0"
    end
  end

  describe "title/0" do
    test "defaults to Teal Naming of the module" do
      assert TestExTeal.OrderAverageMetric.title() == "Order average metric"
    end

    test "can be overriden" do
      assert TestExTeal.NewUserMetric.title() == "New Users"
    end
  end

  describe "average/3" do
    @tag start: 30
    test "calculates the average", %{request: request} do
      insert(:order, grand_total: 10_000, inserted_at: days_ago(10))
      insert(:order, grand_total: 0, inserted_at: days_ago(45))
      insert(:order, grand_total: 10, inserted_at: days_ago(45))

      result = TestExTeal.NewUserMetric.average(request, Order, :grand_total)

      assert result.current == 10_000
      assert result.previous == 5
    end
  end

  describe "maximum/3" do
    @tag start: 30
    test "calculates the max", %{request: request} do
      insert(:order, grand_total: 10_000, inserted_at: days_ago(10))
      insert(:order, grand_total: 0, inserted_at: days_ago(45))
      insert(:order, grand_total: 10, inserted_at: days_ago(45))

      result = TestExTeal.NewUserMetric.maximum(request, Order, :grand_total)

      assert result.current == 10_000
      assert result.previous == 10
    end
  end

  describe "minimum/3" do
    @tag start: 30
    test "calculates the min", %{request: request} do
      insert(:order, grand_total: 10_000, inserted_at: days_ago(10))
      insert(:order, grand_total: 0, inserted_at: days_ago(45))
      insert(:order, grand_total: 10, inserted_at: days_ago(45))

      result = TestExTeal.NewUserMetric.minimum(request, Order, :grand_total)

      assert result.current == 10_000
      assert result.previous == 0
    end
  end

  describe "sum/3" do
    @tag start: 30
    test "calculates the sum", %{request: request} do
      insert(:order, grand_total: 10_000, inserted_at: days_ago(10))
      insert(:order, grand_total: 5, inserted_at: days_ago(45))
      insert(:order, grand_total: 10, inserted_at: days_ago(45))

      result = TestExTeal.NewUserMetric.sum(request, Order, :grand_total)

      assert result.current == 10_000
      assert result.previous == 15
    end
  end

  defp days_ago(days) do
    DateTime.utc_now()
    |> DateTime.add(-1 * days * 60 * 60 * 24)
  end

  defp days_ago_as_str(days) do
    days
    |> days_ago()
    |> Timex.format!("{ISO:Extended}")
  end

  defp request_for_between(start_days, end_days) do
    :get
    |> build_conn("/foo", %{
      "uri" => "new-user",
      "unit" => "day",
      "start_at" => days_ago_as_str(start_days),
      "end_at" => days_ago_as_str(end_days)
    })
    |> Request.from_conn()
  end
end
