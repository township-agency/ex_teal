defmodule ExTeal.Metric.TrendExpressionFactory do
  @moduledoc """
  Factory for selecting the implementation to generate a date factory
  based on the specific database adapter (and database).
  """

  alias ExTeal.Metric.{PostgresTrend}

  @doc """
  Based on the adapter, select a trend factory and build
  a date expression to be used in a Ecto Query fragment for the query
  """
  def make(query, metric, timezone) do
    case metric.repo().__adapter__ do
      Ecto.Adapter.Postgres ->
        PostgresTrend.generate(query, metric, timezone)

      _ ->
        raise ArgumentError, message: "Adapter does not support trend metrics"
    end
  end
end
