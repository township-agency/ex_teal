defmodule ExTeal.Metric.PostgresTrendExpression do
  @moduledoc """
  Trend Expressions for Postgresql databases
  """
  use ExTeal.Metric.TrendExpression

  @impl true
  def generate(query, metric, timezone, unit, start_dt) do
    offset = fetch_offset(timezone, start_dt)
    ts_field_type = metric.date_field_type()

    query
    |> select_based_on_field_type(ts_field_type, metric, unit, offset)
    |> group_by([_q], fragment("date_result"))
    |> order_by([_q], fragment("date_result ASC"))
  end

  def select_based_on_field_type(query, :date, metric, unit, _offset) do
    ts_field = metric.date_field()
    format = date_format(unit)

    select_dt_by_sign(query, "?", ts_field, 0, format)
  end

  def select_based_on_field_type(query, _, metric, unit, offset) do
    ts_field = metric.date_field()
    sign = positive_or_negative(offset)
    interval = to_interval(offset)
    format = date_format(unit)

    select_dt_by_sign(query, sign, ts_field, interval, format)
  end

  defp select_dt_by_sign(query, "+", ts_field, interval, format) do
    select_merge(
      query,
      [q],
      %{
        date_result:
          fragment(
            "to_char(? + interval '? hour', ?) as date_result",
            field(q, ^ts_field),
            ^interval,
            ^format
          )
      }
    )
  end

  defp select_dt_by_sign(query, "-", ts_field, interval, format) do
    select_merge(
      query,
      [q],
      %{
        date_result:
          fragment(
            "to_char(? - '1 hour'::interval * ?, ?) as date_result",
            field(q, ^ts_field),
            ^interval,
            ^format
          )
      }
    )
  end

  defp select_dt_by_sign(query, _, ts_field, _interval, format) do
    select_merge(
      query,
      [q],
      %{
        date_result:
          fragment(
            "to_char(?, ?) as date_result",
            field(q, ^ts_field),
            ^format
          )
      }
    )
  end

  defp date_format("year"), do: "YYYY"
  defp date_format("month"), do: "YYYY-MM"
  defp date_format("week"), do: "IYYY-IW"
  defp date_format("day"), do: "YYYY-MM-DD"
  defp date_format("hour"), do: "YYYY-MM-DD HH24:00"
  defp date_format("minute"), do: "YYYY-MM-DD HH24:mi"

  defp positive_or_negative(offset) when offset > 0, do: "+"
  defp positive_or_negative(offset) when offset == 0, do: ""
  defp positive_or_negative(offset) when offset < 0, do: "-"

  defp to_interval(offset) when offset != 0, do: abs(offset)
  defp to_interval(offset) when offset == 0, do: 0
end
