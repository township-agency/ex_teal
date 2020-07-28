defmodule ExTeal.Metric.TrendExpressionFactory do
  @moduledoc """
  Factory for selecting the implementation to generate a date factory
  based on the specific database adapter (and database).
  """

  alias ExTeal.Metric.PostgresTrendExpression

  @doc """
  Based on the adapter, select a trend factory and build
  a date expression to be used in a Ecto Query fragment for the query
  """
  def make(query, metric, timezone, unit) do
    case metric.repo().__adapter__ do
      Ecto.Adapters.Postgres ->
        PostgresTrendExpression.generate(query, metric, timezone, unit)

      adapter ->
        raise ArgumentError, message: "Adapter #{adapter} does not support trend metrics"
    end
  end
end
