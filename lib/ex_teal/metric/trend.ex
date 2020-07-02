defmodule ExTeal.Metric.Trend do
  @moduledoc """
  Trend metrics display the trend of a computed aggregate over a range
  of time.  For example, a range metric might display the count of new users
  created every day for the last thirty days.

  A Trend metric offers the ability to chose both the range of time that is
  being displayed and the granularity of results.  The granularity is stored as
  as the `range` singluar while the `ranges` includes all available units.

  The available units are:
  - Year
  - Month
  - Week
  - Day
  - Hour
  - Minute

  Some of these data sets will be rather large, so we should provide some safe
  defaults for the maximum number of results returned.

  It would also be nice to be able to display multiple trends on the same graph.

  To do this, a user would specify a calculate like:

  ```
  %{
    paid: count(request, from(Us

  }
  ```
  """

  @type data :: map()

  @callback calculate(ExTeal.Metric.Request.t()) :: data()

  @callback twelve_hour_time() :: boolean()

  @callback date_field() :: atom()

  @callback date_field_type() :: :naive_date_time | :utc_datetime

  defmacro __using__(_opts) do
    quote do
      @behaviour ExTeal.Metric.Trend
      use ExTeal.Resource.Repo
      use ExTeal.Metric.Card

      import Ecto.Query, only: [from: 2]
      import ExTeal.Metric.QueryHelpers

      alias ExTeal.Metric.{Request, Result, Trend}

      def component, do: "range-metric"

      def twelve_hour_time, do: false

      def date_field, do: :inserted_at

      def date_field_type, do: :naive_datetime

      @doc """
      Performs a count query against the specified schema for the requested
      range.
      """
      @spec count(Request.t(), Ecto.Queryable.t(), atom()) :: Trend.data()
      def count(request, queryable, field \\ :id) do
        Trend.aggregate(__MODULE__, request, queryable, :count, field)
      end

      @doc """
      Performs an average query against the specified schema for the requested
      range specified field
      """
      @spec average(Request.t(), Ecto.Queryable.t(), atom()) :: Trend.data()
      def average(request, queryable, field) do
        Trend.aggregate(__MODULE__, request, queryable, :avg, field)
      end

      @doc """
      Performs a max query against the specified schema for the requested
      range specified field
      """
      @spec maximum(Request.t(), Ecto.Queryable.t(), atom()) :: Trend.data()
      def maximum(request, queryable, field) do
        Trend.aggregate(__MODULE__, request, queryable, :max, field)
      end

      @doc """
      Performs a minimum query against the specified schema for the requested
      range specified field
      """
      @spec minimum(Request.t(), Ecto.Queryable.t(), atom()) :: Trend.data()
      def minimum(request, queryable, field) do
        Trend.aggregate(__MODULE__, request, queryable, :min, field)
      end

      @doc """
      Performs a sum query against the specified schema for the requested
      range specified field
      """
      @spec sum(Request.t(), Ecto.Queryable.t(), atom()) :: Trend.data()
      def sum(request, queryable, field) do
        Trend.aggregate(__MODULE__, request, queryable, :sum, field)
      end

      defoverridable twelve_hour_time: 0, date_field: 0
    end
  end

  use Timex
  import Ecto.Query
  alias ExTeal.Metric.{Request, TrendExpressionFactory}

  @spec aggregate(module(), Request.t(), Ecto.Queryable.t(), atom(), atom()) :: data()
  def aggregate(metric, request, query, aggregate_type, field) do
    timezone = Request.resolve_timezone(request)
    twelve_hour_time = metric.twelve_hour_time()
    {starting_dt, end_dt} = get_aggregate_datetimes(request, timezone)
    possible_results = get_possible_results(starting_dt, end_dt, request, twelve_hour_time)

    query
    |> TrendExpressionFactory.make(metric, timezone, request.range)
  end

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
  def get_aggregate_datetimes(%Request{range: range, conn: conn}, timezone) do
    start_param = Map.get(conn.params, "start")
    end_param = Map.get(conn.params, "end", "now")

    case range do
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

  def get_possible_results(start_dt, end_dt, request, twelve_hour_time \\ false) do
    [from: start_dt, until: end_dt, step: step_for(request.range)]
    |> Interval.new()
    |> Enum.map(&to_result_date(&1, request.range, twelve_hour_time))
  end

  def to_result_date(datetime, "year", _), do: Timex.format!(datetime, "{YYYY}")
  def to_result_date(datetime, "month", _), do: Timex.format!(datetime, "{Mfull} {YYYY}")

  def to_result_date(datetime, "week", _) do
    [from: Timex.beginning_of_week(datetime), until: Timex.end_of_week(datetime)]
    |> Interval.new()
    |> Interval.format!("{Mfull} {D}", Timex.Format.DateTime.Formatters.Default)
    |> String.replace(["[", ")"], "")
    |> String.split(",", trim: true)
    |> Enum.join(" -")
  end

  def to_result_date(datetime, "day", _), do: Timex.format!(datetime, "{Mfull} {D} {YYYY}")

  def to_result_date(datetime, "hour", true),
    do: Timex.format!(datetime, "{Mfull} {D} {YYYY} {h12}:00 {am}")

  def to_result_date(datetime, "hour", false),
    do: Timex.format!(datetime, "{Mfull} {D} {YYYY} {h24}:00")

  def to_result_date(datetime, "minute", true),
    do: Timex.format!(datetime, "{Mfull} {D} {YYYY} {h12}:{m} {am}")

  def to_result_date(datetime, "minute", false),
    do: Timex.format!(datetime, "{Mfull} {D} {YYYY} {h24}:{m}")

  defp step_for("year"), do: [years: 1]
  defp step_for("month"), do: [months: 1]
  defp step_for("week"), do: [weeks: 1]
  defp step_for("day"), do: [days: 1]
  defp step_for("hour"), do: [hours: 1]
  defp step_for("minute"), do: [minutes: 1]

  defp parse_dt("now", _format, timezone) do
    timezone
    |> DateTime.now!()
    |> DateTime.truncate(:second)
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
end
