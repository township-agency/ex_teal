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
  """

  @type data :: map()

  @callback calculate(ExTeal.Metric.Request.t()) :: data()

  @callback twelve_hour_time() :: boolean()

  @callback date_field() :: atom()

  @callback date_field_type() :: :naive_date_time | :utc_datetime

  @callback precision :: integer()

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

      def precision, do: 0

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

      defoverridable twelve_hour_time: 0, date_field: 0, precision: 0
    end
  end

  use Timex
  import Ecto.Query
  alias ExTeal.Metric.{Request, TrendExpressionFactory}

  @spec aggregate(module(), Request.t(), Ecto.Queryable.t(), atom(), atom()) :: data()
  def aggregate(metric, request, query, aggregate_type, field) do
    timezone = Request.resolve_timezone(request.conn)
    twelve_hour_time = metric.twelve_hour_time()
    {starting_dt, end_dt} = get_aggregate_datetimes(request, timezone)
    possible_results = get_possible_results(starting_dt, end_dt, request, twelve_hour_time)

    results =
      query
      |> aggregate_as(aggregate_type, field)
      |> TrendExpressionFactory.make(metric, timezone, request.range)
      |> between(
        start_dt: starting_dt,
        end_dt: end_dt,
        metric: metric
      )
      |> metric.repo().all()
      |> Enum.into(%{}, &format_result_data(&1, request.range, twelve_hour_time))

    precision = metric.precision()

    Enum.map(possible_results, fn k ->
      value = results |> Map.get(k, 0) |> Decimal.new()

      %{date: k, value: Decimal.round(value, precision)}
    end)
  end

  @year_format "{YYYY}"
  @month_format "{YYYY}-{0M}"
  @day_format "{YYYY}-{M}-{D}"
  @dt_format "{YYYY}-{0M}-{0D} {h24}:{m}:{s}"

  @doc """
  Takes a database record transforms it into a two-tuple of the date_result
  parsed into an appropriate format and a
  """
  @spec format_result_data(map(), String.t(), boolean()) :: {String.t(), number}
  def format_result_data(%{date_result: date, aggregate: val}, unit, twelve_hour) do
    date =
      case unit do
        "year" ->
          date

        "month" ->
          {:ok, dt} = Timex.parse(date, @month_format)
          to_result_date(dt, "month", false)

        "week" ->
          {:ok, dt} = Timex.parse(date, "{YYYY}-{Wiso}")
          to_result_date(dt, "week", false)

        "day" ->
          {:ok, dt} = Timex.parse(date, "{YYYY}-{0M}-{0D}")
          to_result_date(dt, "day", false)

        "hour" ->
          {:ok, dt} = Timex.parse(date, "{YYYY}-{0M}-{0D} {h24}:{m}")
          to_result_date(dt, "hour", twelve_hour)

        "minute" ->
          {:ok, dt} = Timex.parse(date, "{YYYY}-{0M}-{0D} {h24}:{m}:{s}")
          to_result_date(dt, "minute", twelve_hour)

        true ->
          nil
      end

    {date, val}
  end

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

  @doc """
  Build a select for the field and aggregate type
  """
  @spec aggregate_as(Ecto.Queryable.t(), atom(), atom()) :: Ecto.Queryable.t()
  def aggregate_as(query, :count, f) do
    select(query, [q], %{aggregate: count(field(q, ^f))})
  end

  def aggregate_as(query, :sum, f) do
    select(query, [q], %{aggregate: sum(field(q, ^f))})
  end

  def aggregate_as(query, :min, f) do
    select(query, [q], %{aggregate: min(field(q, ^f))})
  end

  def aggregate_as(query, :max, f) do
    select(query, [q], %{aggregate: max(field(q, ^f))})
  end

  def aggregate_as(query, :avg, f) do
    select(query, [q], %{aggregate: avg(field(q, ^f))})
  end

  defp to_dt_field_type(value, :naive_datetime) do
    utc = Timezone.get("Etc/UTC", value)
    Timezone.convert(value, utc)
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
