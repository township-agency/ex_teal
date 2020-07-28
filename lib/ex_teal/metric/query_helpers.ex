defmodule ExTeal.Metric.QueryHelpers do
  @moduledoc """
  Composeable Queries Helpers for Building Metrics
  """
  @spec parse(integer() | nil | Decimal.t()) :: integer() | float()
  def parse(val) when is_integer(val), do: val

  def parse(nil), do: 0

  def parse(%Decimal{} = val), do: val |> Decimal.round(2) |> Decimal.to_float()
end
