defmodule ExTeal.Metric.ValueTest do
  use TestExTeal.ConnCase
  alias ExTeal.Metric.{Request, Result}
  alias TestExTeal.{Order, User}

  defmodule TestExTeal.NewUserMetric do
    use ExTeal.Metric.Value

    def calculate(request) do
      count(request, User)
    end

    def ranges,
      do: %{
        30 => "30 Days",
        90 => "90 Days"
      }

    def uri, do: "new-user"
    def title, do: "New Users"
  end

  defmodule TestExTeal.OrderAverageMetric do
    use ExTeal.Metric.Value
    def calculate(request), do: average(request, Order, :grand_total)
    def ranges, do: %{30 => "30 Days"}
    def prefix, do: "$"
    def suffix, do: "Total"
    def format, do: "0,0"
  end

  describe "count/2" do
    test "returns a value result" do
      result = TestExTeal.NewUserMetric.count(%Request{range: 30}, User)
      assert result
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
    test "defaults to nil" do
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
      assert TestExTeal.NewUserMetric.format() == nil
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
    test "calculates the average" do
      insert(:order, grand_total: 10_000, inserted_at: days_ago(10))
      insert(:order, grand_total: 0, inserted_at: days_ago(45))
      insert(:order, grand_total: 10, inserted_at: days_ago(45))

      result = TestExTeal.NewUserMetric.average(%Request{range: 30}, Order, :grand_total)

      assert result.current == 10_000
      assert result.previous == 5

      insert(:order, grand_total: 0, inserted_at: days_ago(45))

      second_result = TestExTeal.NewUserMetric.average(%Request{range: 30}, Order, :grand_total)

      assert second_result.previous == 3.33
    end
  end

  describe "maximum/3" do
    test "calculates the max" do
      insert(:order, grand_total: 10_000, inserted_at: days_ago(10))
      insert(:order, grand_total: 0, inserted_at: days_ago(45))
      insert(:order, grand_total: 10, inserted_at: days_ago(45))

      result = TestExTeal.NewUserMetric.maximum(%Request{range: 30}, Order, :grand_total)

      assert result.current == 10_000
      assert result.previous == 10
    end
  end

  describe "minimum/3" do
    test "calculates the max" do
      insert(:order, grand_total: 10_000, inserted_at: days_ago(10))
      insert(:order, grand_total: 0, inserted_at: days_ago(45))
      insert(:order, grand_total: 10, inserted_at: days_ago(45))

      result = TestExTeal.NewUserMetric.minimum(%Request{range: 30}, Order, :grand_total)

      assert result.current == 10_000
      assert result.previous == 0
    end
  end

  describe "sum/3" do
    test "calculates the sum" do
      insert(:order, grand_total: 10_000, inserted_at: days_ago(10))
      insert(:order, grand_total: 5, inserted_at: days_ago(45))
      insert(:order, grand_total: 10, inserted_at: days_ago(45))

      result = TestExTeal.NewUserMetric.sum(%Request{range: 30}, Order, :grand_total)

      assert result.current == 10_000
      assert result.previous == 15
    end
  end

  defp days_ago(days) do
    DateTime.utc_now()
    |> DateTime.add(-1 * days * 60 * 60 * 24)
  end
end
