defmodule ExTeal.Metric.Value do
  @moduledoc """
  Value Metrics display a single value and it's change compared to a previous
  interval of time.  For example, a value metric might display the total number
  of blog posts created in the last thirty days, versus the previous thirty days.

  Once generated, a value metric module has two functions that can be customized,
  a `calculate/1` and a `ranges/0` function.

  Additionally there are modifier functions that change the behavior and display
  of the metric.
  """

  @type data :: %{current: term(), previous: term()}

  @callback calculate(ExTeal.Metric.Request.t()) :: data()

  defmacro __using__(_opts) do
    quote do
      @behaviour ExTeal.Metric.Value
      use ExTeal.Metric

      alias ExTeal.Metric.{Request, Result, Value}

      def component, do: "value-metric"

      @doc """
      Performs a count query against the specified schema for the requested
      range.
      """
      @spec count(Request.t(), Ecto.Queryable.t(), atom()) :: Value.data()
      def count(request, query, field \\ :id) do
        Value.aggregate(__MODULE__, request, query, :count, field)
      end

      @doc """
      Performs an average query against the specified schema for the requested
      range specified field
      """
      @spec average(Request.t(), Ecto.Queryable.t(), atom()) :: Value.data()
      def average(request, query, field) do
        Value.aggregate(__MODULE__, request, query, :avg, field)
      end

      @doc """
      Performs a max query against the specified schema for the requested
      range specified field
      """
      @spec maximum(Request.t(), Ecto.Queryable.t(), atom()) :: Value.data()
      def maximum(request, query, field) do
        Value.aggregate(__MODULE__, request, query, :max, field)
      end

      @doc """
      Performs a minimum query against the specified schema for the requested
      range specified field
      """
      @spec minimum(Request.t(), Ecto.Queryable.t(), atom()) :: Value.data()
      def minimum(request, query, field) do
        Value.aggregate(__MODULE__, request, query, :min, field)
      end

      @doc """
      Performs a sum query against the specified schema for the requested
      range specified field
      """
      @spec sum(Request.t(), Ecto.Queryable.t(), atom()) :: Value.data()
      def sum(request, query, field) do
        Value.aggregate(__MODULE__, request, query, :sum, field)
      end
    end
  end

  use Timex
  alias ExTeal.Metric.Request
  import ExTeal.Metric.QueryHelpers
  import ExTeal.Metric.Ranges

  @spec aggregate(module(), Request.t(), Ecto.Queryable.t(), atom(), atom()) :: map()
  def aggregate(metric_module, request, queryable, aggregate_type, field) do
    %{
      previous: query_for(:previous, metric_module, request, queryable, aggregate_type, field),
      current: query_for(:current, metric_module, request, queryable, aggregate_type, field)
    }
  end

  @spec query_for(atom(), module(), Request.t(), Ecto.Queryable.t(), atom(), atom()) ::
          integer() | float()
  def query_for(current, metric, request, queryable, aggregate_type, field) do
    timezone = Request.resolve_timezone(request.conn)
    {start_dt, end_dt} = get_aggregate_datetimes(request, timezone)

    queryable
    |> between_current(current, start_dt: start_dt, end_dt: end_dt, metric: metric)
    |> metric.repo().aggregate(aggregate_type, field)
    |> parse()
  end

  def between_current(query, :current, options) do
    between(query, options)
  end

  def between_current(query, :previous, start_dt: start_dt, end_dt: end_dt, metric: metric) do
    duration =
      Interval.new(from: start_dt, until: end_dt)
      |> Interval.duration(:duration)

    between(query, start_dt: Timex.subtract(start_dt, duration), end_dt: start_dt, metric: metric)
  end
end
