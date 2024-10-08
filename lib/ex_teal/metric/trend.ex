defmodule ExTeal.Metric.Trend do
  @moduledoc """
  Trend metrics display the trend of a computed aggregate over a range
  of time.  For example, a trend metric might display the count of new users
  created every day for the last thirty days.

  A Trend metric offers the ability to chose both the range of time that is
  being displayed and the granularity of results.  The granularity is stored as
  as the `unit` singluar while the `ranges` includes all available units.

  The available units are:
  - year
  - month
  - week
  - day
  - hour
  - minute

  Some of these data sets will be rather large, so we should provide some safe
  defaults for the maximum number of results returned.
  """

  @type result :: map()

  @type multi_result :: map()

  @type valid_result :: result() | [multi_result()]

  @callback twelve_hour_time() :: boolean()

  @callback calculate(ExTeal.Metric.Request.t()) :: valid_result()

  @callback cast(Decimal.t()) :: any()

  @callback precision() :: integer()

  defmacro __using__(_opts) do
    quote do
      @behaviour ExTeal.Metric.Trend
      use ExTeal.Metric

      import Ecto.Query, only: [from: 2]
      import ExTeal.Metric.QueryHelpers

      alias ExTeal.Metric.{Request, Result, Trend}

      def component, do: "trend-metric"

      def twelve_hour_time, do: false

      def precision, do: 0

      @doc """
      Performs a count query against the specified schema for the requested
      range.
      """
      @spec count(Request.t(), Ecto.Queryable.t(), atom(), map()) :: Trend.result()
      def count(request, queryable, field \\ :id, series_options \\ %{}) do
        Trend.aggregate(__MODULE__, request, queryable, :count, field, series_options)
      end

      @doc """
      Performs an average query against the specified schema for the requested
      range specified field
      """
      @spec average(Request.t(), Ecto.Queryable.t(), atom()) :: Trend.result()
      def average(request, queryable, field, series_options \\ %{}) do
        Trend.aggregate(__MODULE__, request, queryable, :avg, field, series_options)
      end

      @doc """
      Performs a max query against the specified schema for the requested
      range specified field
      """
      @spec maximum(Request.t(), Ecto.Queryable.t(), atom()) :: Trend.result()
      def maximum(request, queryable, field, series_options \\ %{}) do
        Trend.aggregate(__MODULE__, request, queryable, :max, field, series_options)
      end

      @doc """
      Performs a minimum query against the specified schema for the requested
      range specified field
      """
      @spec minimum(Request.t(), Ecto.Queryable.t(), atom(), map()) :: Trend.result()
      def minimum(request, queryable, field, series_options \\ %{}) do
        Trend.aggregate(__MODULE__, request, queryable, :min, field, series_options)
      end

      @doc """
      Performs a sum query against the specified schema for the requested
      range specified field
      """
      @spec sum(Request.t(), Ecto.Queryable.t(), atom()) :: Trend.result()
      def sum(request, queryable, field, series_options \\ %{}) do
        Trend.aggregate(__MODULE__, request, queryable, :sum, field, series_options)
      end

      def cast(decimal), do: decimal

      defoverridable twelve_hour_time: 0, precision: 0, cast: 1
    end
  end

  use Timex
  import Ecto.Query
  import ExTeal.Metric.Ranges
  alias ExTeal.Metric.{Request, TrendExpressionFactory}

  @spec aggregate(module(), Request.t(), Ecto.Queryable.t(), atom(), atom(), map()) :: result()
  def aggregate(metric, request, query, aggregate_type, field, series_options) do
    {start_dt, end_dt} = get_aggregate_datetimes(request)
    timezone = start_dt.time_zone
    possible_results = get_possible_results(start_dt, end_dt, request, timezone)

    results =
      query
      |> aggregate_as(aggregate_type, field)
      |> TrendExpressionFactory.make(metric, timezone, request.unit, start_dt)
      |> between(
        start_dt: start_dt,
        end_dt: end_dt,
        metric: metric
      )
      |> metric.repo().all()
      |> Enum.into(%{}, &format_result_data(&1, request.unit, timezone))

    precision = metric.precision()

    data =
      Enum.map(possible_results, fn k ->
        value =
          results
          |> Map.get(k, 0)
          |> metric.cast()
          |> to_decimal()
          |> Decimal.round(precision)

        %{x: k, y: value}
      end)

    Map.merge(series_options, %{data: data})
  end

  @doc """
  Takes a database record transforms it into a two-tuple of the date_result
  parsed into an appropriate format
  """
  @spec format_result_data(map(), String.t(), String.t()) :: {String.t(), number}
  def format_result_data(
        %{date_result: date, aggregate: val},
        unit,
        timezone
      ) do
    format = result_format(unit)

    date =
      date
      |> to_local_dt(format, timezone)
      |> to_result_date()

    {date, val}
  end

  defp result_format("year"), do: "{YYYY}"
  defp result_format("month"), do: "{YYYY}-{0M}"
  defp result_format("week"), do: "{YYYY}-{Wiso}"
  defp result_format("day"), do: "{YYYY}-{0M}-{0D}"
  defp result_format("hour"), do: "{YYYY}-{0M}-{0D} {h24}:{m}"
  defp result_format(_), do: "{YYYY}-{0M}-{0D} {h24}:{m}"

  def get_possible_results(start_dt, end_dt, request, timezone) do
    tz = Timezone.get(timezone, start_dt)

    [from: start_dt, until: end_dt, step: step_for(request.unit)]
    |> Interval.new()
    |> Enum.map(fn val ->
      val
      |> DateTime.from_naive!("Etc/UTC")
      |> Timezone.convert(tz)
      |> to_result_date()
    end)
  end

  @spec to_local_dt(String.t(), String.t(), String.t()) :: DateTime.t()
  def to_local_dt(db_date, format, timezone) do
    db_date
    |> Timex.parse!(format)
    |> Timex.Timezone.convert(timezone)
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

  @spec to_result_date(DateTime.t()) :: String.t()
  def to_result_date(datetime),
    do: datetime |> DateTime.truncate(:second) |> Timex.format!("{ISO:Extended}")

  defp step_for("year"), do: [years: 1]
  defp step_for("month"), do: [months: 1]
  defp step_for("week"), do: [weeks: 1]
  defp step_for("day"), do: [days: 1]
  defp step_for("hour"), do: [hours: 1]
  defp step_for("minute"), do: [minutes: 1]

  defp to_decimal(float) when is_float(float), do: Decimal.from_float(float)

  defp to_decimal(value) when is_integer(value), do: Decimal.new(value)

  defp to_decimal(%Decimal{} = val), do: val

  defp to_decimal(_val), do: Decimal.new(0)
end
