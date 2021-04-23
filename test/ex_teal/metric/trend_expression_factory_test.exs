defmodule ExTeal.Metric.TrendExpressionFactoryTest do
  use ExUnit.Case, async: true

  alias ExTeal.Metric.TrendExpressionFactory
  alias TestExTeal.User

  defmodule Foo do
    def __adapter__, do: Ecto.Adapters.MyXQL
  end

  defmodule FooTrend do
    use ExTeal.Metric.Trend

    @impl true
    def calculate(request) do
      count(request, User)
    end

    @impl true
    def repo, do: Foo
  end

  describe "make/1" do
    test "throws an error for an unsupported adapter" do
      assert_raise ArgumentError, fn ->
        TrendExpressionFactory.make(User, FooTrend, "Etc/UTC", "day", Timex.now())
      end
    end
  end
end
