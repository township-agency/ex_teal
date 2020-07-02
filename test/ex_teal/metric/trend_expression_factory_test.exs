defmodule ExTeal.Metric.TrendExpressionFactoryTest do
  use ExUnit.Case, async: true

  alias ExTeal.Metric.TrendExpressionFactory

  describe "make/1" do
    test "throws an error for an unsupported adapter" do
      assert_raise ArgumentError, fn ->
        TrendExpressionFactory.make(String, %Request{})
      end
    end
  end
end
