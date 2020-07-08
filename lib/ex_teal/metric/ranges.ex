defmodule ExTeal.Metric.Ranges do
  @moduledoc """
  Helper functions for building time intervals and
  queries based on the params of a request.
  """

  use Timex
  import Ecto.Query
  alias ExTeal.Metric.Request

  @year_format "{YYYY}"
  @month_format "{YYYY}-{0M}"
  @day_format "{YYYY}-{M}-{D}"
  @dt_format "{YYYY}-{0M}-{0D} {h24}:{m}:{s}"

  @doc """
  Parse the start and end params
  """
  @spec get_aggregate_datetimes(
          request :: Request.t(),
          timezone :: String.t()
        ) ::
          {start :: DateTime.t(), end_dt :: DateTime.t()}
  def get_aggregate_datetimes(
        %Request{unit: unit, start_at: start_param, end_at: end_param},
        timezone
      ) do
    case unit do
      "year" ->
        {
          start_param |> parse_dt(@year_format, timezone) |> Timex.beginning_of_year(),
          end_param |> parse_dt(@year_format, timezone) |> Timex.end_of_year()
        }

      "month" ->
        {
          start_param |> parse_dt(@month_format, timezone) |> Timex.beginning_of_month(),
          end_param |> parse_dt(@month_format, timezone) |> Timex.end_of_month()
        }

      "week" ->
        {
          start_param |> parse_dt(@day_format, timezone) |> Timex.beginning_of_week(),
          end_param |> parse_dt(@day_format, timezone) |> Timex.end_of_week()
        }

      "day" ->
        {
          start_param |> parse_dt(@day_format, timezone) |> Timex.beginning_of_day(),
          end_param |> parse_dt(@day_format, timezone) |> Timex.end_of_day()
        }

      "hour" ->
        {
          start_param |> parse_dt(@dt_format, timezone) |> start_of_hour(),
          end_param |> parse_dt(@dt_format, timezone) |> end_of_hour()
        }

      "minute" ->
        {
          start_param |> parse_dt(@dt_format, timezone) |> start_of_minute(),
          end_param |> parse_dt(@dt_format, timezone) |> end_of_minute()
        }
    end
  end

  @type between_options :: [start_dt: DateTime.t(), end_dt: DateTime.t(), metric: module()]

  @doc """
  Set the boundaries of an aggregate queries
  """
  @spec between(Ecto.Queryable.t(), between_options()) :: Ecto.Queryable.t()
  def between(query, start_dt: start, end_dt: end_dt, metric: metric) do
    dt_field = metric.date_field()

    field_type = metric.date_field_type()

    query
    |> where([q], field(q, ^dt_field) >= ^to_dt_field_type(start, field_type))
    |> where([q], field(q, ^dt_field) <= ^to_dt_field_type(end_dt, field_type))
  end

  defp parse_dt(param, format, timezone) do
    param
    |> Timex.parse!(format)
    |> DateTime.from_naive!(timezone)
  end

  defp start_of_hour(datetime) do
    {date, {h, _m, _s}} = Timex.to_erl(datetime)
    Timex.to_datetime({date, {h, 0, 0}}, datetime.time_zone)
  end

  defp end_of_hour(datetime) do
    {date, {h, _m, _s}} = Timex.to_erl(datetime)
    Timex.to_datetime({date, {h, 59, 59}}, datetime.time_zone)
  end

  defp start_of_minute(datetime) do
    {date, {h, m, _s}} = Timex.to_erl(datetime)
    Timex.to_datetime({date, {h, m, 0}}, datetime.time_zone)
  end

  defp end_of_minute(datetime) do
    {date, {h, m, _s}} = Timex.to_erl(datetime)
    Timex.to_datetime({date, {h, m, 59}}, datetime.time_zone)
  end

  defp to_dt_field_type(value, :naive_datetime) do
    utc = Timezone.get("Etc/UTC", value)
    Timezone.convert(value, utc)
  end
end
