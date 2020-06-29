defmodule ExTeal.Metric.QueryHelpers do
  @moduledoc """
  Composeable Queries for Building Metrics
  """

  import Ecto.Query
  alias ExTeal.Metric.{Request, ValueResult}

  def query_for_with_result(metric, request, module, aggregate, field) do
    metric
    |> base_result(request)
    |> struct(%{
      current: query_for(:current, metric, request, module, aggregate, field),
      previous: query_for(:previous, metric, request, module, aggregate, field)
    })
  end

  defp base_result(metric, request) do
    %ValueResult{
      uri: metric.uri(),
      ranges: metric.ranges(),
      range: request.range,
      prefix: metric.prefix(),
      suffix: metric.suffix(),
      format: metric.format()
    }
  end

  def query_for(current, metric, request, module, aggregate_type, field) do
    module
    |> metric.base_query()
    |> where_before(current, request)
    |> where_after(current, request)
    |> metric.repo().aggregate(aggregate_type, field)
    |> parse()
  end

  def parse(val) when is_integer(val), do: val

  def parse(nil), do: 0

  def parse(%Decimal{} = val), do: val |> Decimal.round(2) |> Decimal.to_float()

  def where_before(query, :current, %Request{range: range})
      when is_integer(range) do
    where(query, [q], q.inserted_at >= ^days_ago(range))
  end

  def where_before(query, :previous, %Request{range: range})
      when is_integer(range) do
    where(query, [q], q.inserted_at >= ^days_ago(range * 2))
  end

  def where_after(query, :current, %Request{range: range})
      when is_integer(range) do
    now = DateTime.utc_now()
    where(query, [q], q.inserted_at < ^now)
  end

  def where_after(query, :previous, %Request{range: range}) do
    where(query, [q], q.inserted_at < ^days_ago(range))
  end

  defp days_ago(days) do
    DateTime.utc_now()
    |> DateTime.add(-1 * 60 * 60 * 24 * days, :second)
  end
end
