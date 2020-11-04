defmodule ExTeal.Metric.TrendExpressionTest do
  use ExUnit.Case

  alias ExTeal.Metric.TrendExpression

  test "fetch_offset/1 returns the offset in hours" do
    assert TrendExpression.fetch_offset("Etc/UTC") == 0
    assert TrendExpression.fetch_offset("America/Chicago")
  end
end
