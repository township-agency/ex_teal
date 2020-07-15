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

  It would also be nice to be able to display multiple trends on the same graph.
  """
  @type data :: %{aggregate: term(), date_result: String.t()}

  @callback twelve_hour_time() :: boolean()

  @callback calculate(ExTeal.Metric.Request.t()) :: [data()]

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

      def options, do: %{uri: uri()}

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
  import ExTeal.Metric.Ranges
  alias ExTeal.Metric.{Request, TrendExpressionFactory}

  @spec aggregate(module(), Request.t(), Ecto.Queryable.t(), atom(), atom()) :: [map()]
  def aggregate(metric, request, query, aggregate_type, field) do
    twelve_hour_time = metric.twelve_hour_time()
    {start_dt, end_dt} = get_aggregate_datetimes(request)
    timezone = start_dt.date_time
    possible_results = get_possible_results(start_dt, end_dt, request, twelve_hour_time)

    results =
      query
      |> aggregate_as(aggregate_type, field)
      |> TrendExpressionFactory.make(metric, timezone, request.unit)
      |> between(
        start_dt: start_dt,
        end_dt: end_dt,
        metric: metric
      )
      |> metric.repo().all()
      |> Enum.into(%{}, &format_result_data(&1, request.unit, timezone, twelve_hour_time))

    precision = metric.precision()

    Enum.map(possible_results, fn k ->
      value = results |> Map.get(k, 0) |> Decimal.new()

      %{date: k, value: Decimal.round(value, precision)}
    end)
  end

  @doc """
  Takes a database record transforms it into a two-tuple of the date_result
  parsed into an appropriate format
  """
  @spec format_result_data(map(), String.t(), String.t(), boolean()) :: {String.t(), number}
  def format_result_data(
        %{date_result: date, aggregate: val},
        unit,
        timezone,
        twelve_hour
      ) do
    date =
      case unit do
        "year" ->
          date

        "month" ->
          date
          |> to_local_dt("{YYYY}-{0M}", timezone)
          |> to_result_date("month", false)

        "week" ->
          date
          |> to_local_dt("{YYYY}-{Wiso}", timezone)
          |> to_result_date("week", false)

        "day" ->
          date
          |> to_local_dt("{YYYY}-{0M}-{0D}", timezone)
          |> to_result_date("day", false)

        "hour" ->
          date
          |> to_local_dt("{YYYY}-{0M}-{0D} {h24}:{m}", timezone)
          |> to_result_date("hour", twelve_hour)

        "minute" ->
          date
          |> to_local_dt("{YYYY}-{0M}-{0D} {h24}:{m}:{s}", timezone)
          |> to_result_date("minute", twelve_hour)

        true ->
          nil
      end

    {date, val}
  end

  def get_possible_results(start_dt, end_dt, request, timezone, twelve_hour_time \\ false) do
    [from: start_dt, until: end_dt, step: step_for(request.unit)]
    |> Interval.new()
    |> Enum.map(&to_result_date(&1, request.unit, twelve_hour_time))
  end

  @spec to_local_dt(String.t(), String.t(), String.t()) :: DateTime.t()
  def to_local_dt(db_date, format, timezone) do
    db_date
    |> Timex.parse!(format)
    |> DateTime.from_naive!(timezone)
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

  def to_result_date(datetime, "minute", false) do
    Timex.format!(datetime, "{Mfull} {D} {YYYY} {h24}:{m}")
  end

  defp step_for("year"), do: [years: 1]
  defp step_for("month"), do: [months: 1]
  defp step_for("week"), do: [weeks: 1]
  defp step_for("day"), do: [days: 1]
  defp step_for("hour"), do: [hours: 1]
  defp step_for("minute"), do: [minutes: 1]
end
