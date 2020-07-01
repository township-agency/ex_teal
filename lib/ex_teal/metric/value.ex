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

  @type range_key :: String.t() | integer

  @type data :: %{current: term(), previous: term()}

  @callback calculate(ExTeal.Metric.Request.t()) :: data()

  @callback ranges() :: %{required(range_key) => String.t()}

  defmacro __using__(_opts) do
    quote do
      @behaviour ExTeal.Metric.Value
      use ExTeal.Resource.Repo
      use ExTeal.Metric.Card

      import Ecto.Query, only: [from: 2]

      alias ExTeal.Metric.{Request, Result, Value}

      def component, do: "value-metric"

      @doc """
      Performs a count query against the specified schema for the requested
      range.
      """
      @spec count(Request.t(), module(), atom()) :: Value.data()
      def count(request, module, field \\ :id) do
        Value.aggregate(__MODULE__, request, module, :count, field)
      end

      @doc """
      Performs an average query against the specified schema for the requested
      range specified field
      """
      @spec average(Request.t(), module(), atom()) :: Value.data()
      def average(request, module, field) do
        Value.aggregate(__MODULE__, request, module, :avg, field)
      end

      @doc """
      Performs a max query against the specified schema for the requested
      range specified field
      """
      @spec maximum(Request.t(), module(), atom()) :: Value.data()
      def maximum(request, module, field) do
        Value.aggregate(__MODULE__, request, module, :max, field)
      end

      @doc """
      Performs a minimum query against the specified schema for the requested
      range specified field
      """
      @spec minimum(Request.t(), module(), atom()) :: Value.data()
      def minimum(request, module, field) do
        Value.aggregate(__MODULE__, request, module, :min, field)
      end

      @doc """
      Performs a sum query against the specified schema for the requested
      range specified field
      """
      @spec sum(Request.t(), module(), atom()) :: Value.data()
      def sum(request, module, field) do
        Value.aggregate(__MODULE__, request, module, :sum, field)
      end
    end
  end

  alias ExTeal.Metric.Request
  import Ecto.Query, only: [where: 3]
  import ExTeal.Metric.QueryHelpers

  def aggregate(metric_module, request, queryable, aggregate_type, field) do
    %{
      previous: query_for(:previous, metric_module, request, queryable, aggregate_type, field),
      current: query_for(:current, metric_module, request, queryable, aggregate_type, field)
    }
  end

  def query_for(current, metric, request, queryable, aggregate_type, field) do
    queryable
    |> where_before(current, request)
    |> where_after(current, request)
    |> metric.repo().aggregate(aggregate_type, field)
    |> parse()
  end

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
