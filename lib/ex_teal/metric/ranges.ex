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
  @week_format "{YYYY}-{Wiso}"
  @day_format "{YYYY}-{0M}-{0D}"
  @dt_format "{YYYY}-{0M}-{0D} {h24}:{m}:{s}"

  @doc """
  Parse the start and end params
  """
  @spec get_aggregate_datetimes(request :: Request.t()) ::
          {start_dt :: DateTime.t(), end_dt :: DateTime.t()}
  def get_aggregate_datetimes(%Request{unit: unit} = request) do
    request
    |> to_datetimes()
    |> aggregate_as(unit)
  end

  defp to_datetimes(%Request{start_at: start_param, end_at: end_param}) do
    {
      Timex.parse!(start_param, "{ISO:Extended}"),
      Timex.parse!(end_param, "{ISO:Extended}")
    }
  end

  defp aggregate_as({start_at, end_at}, "year") do
    {
      Timex.beginning_of_year(start_at),
      Timex.end_of_year(end_at)
    }
  end

  defp aggregate_as({start_at, end_at}, "month") do
    {
      Timex.beginning_of_month(start_at),
      Timex.end_of_month(end_at)
    }
  end

  defp aggregate_as({start_at, end_at}, "week") do
    {
      Timex.beginning_of_week(start_at),
      Timex.end_of_week(end_at)
    }
  end

  defp aggregate_as({start_at, end_at}, "day") do
    {
      Timex.beginning_of_day(start_at),
      Timex.end_of_day(end_at)
    }
  end

  defp aggregate_as({start_at, end_at}, "hour") do
    {
      beginning_of_hour(start_at),
      end_of_hour(end_at)
    }
  end

  defp aggregate_as({start_at, end_at}, "minute") do
    {
      beginning_of_minute(start_at),
      end_of_minute(end_at)
    }
  end

  @type between_options :: [start_dt: DateTime.t(), end_dt: DateTime.t(), metric: module()]

  @doc """
  Set the boundaries of an aggregate queries
  """
  @spec between(Ecto.Queryable.t(), between_options()) :: Ecto.Queryable.t()
  def between(query, start_dt: start, end_dt: end_dt, metric: metric) do
    dt_field = metric.date_field()

    field_type = metric.date_field_type()
    start_time = to_dt_field_type(start, field_type)
    end_time = to_dt_field_type(end_dt, field_type)

    query
    |> where([q], field(q, ^dt_field) >= ^start_time)
    |> where([q], field(q, ^dt_field) <= ^end_time)
  end

  @spec parse_dt(String.t(), String.t(), String.t()) :: DateTime.t()
  def parse_dt(param, format, timezone) do
    param
    |> Timex.parse!(format)
    |> DateTime.from_naive!(timezone)
  end

  defp beginning_of_hour(datetime) do
    {date, {h, _m, _s}} = Timex.to_erl(datetime)
    Timex.to_datetime({date, {h, 0, 0}}, datetime.time_zone)
  end

  defp end_of_hour(datetime) do
    {date, {h, _m, _s}} = Timex.to_erl(datetime)
    Timex.to_datetime({date, {h, 59, 59}}, datetime.time_zone)
  end

  defp beginning_of_minute(datetime) do
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
