defmodule ExTeal.Metric.TrendExpressionTest do
  use ExUnit.Case

  alias ExTeal.Metric.TrendExpression

  test "fetch_offset/2 returns the offset in hours" do
    assert TrendExpression.fetch_offset("Etc/UTC", Timex.now()) == 0
    assert TrendExpression.fetch_offset("America/Chicago", Timex.now())
  end
end
