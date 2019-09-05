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

  alias ExTeal.Metric.ValueRequest

  @type range_key :: String.t() | integer

  @callback calculate(ExTeal.Metric.ValueRequest.t()) :: {:ok, ExTeal.Metric.ValueResult.t()}

  @callback ranges() :: %{required(range_key) => String.t()}

  @callback prefix() :: String.t()

  @callback suffix() :: String.t()

  @callback format() :: String.t()

  @callback only_on_detail() :: boolean

  defmacro __using__(_opts) do
    quote do
      @behaviour ExTeal.Metric.Value
      use ExTeal.Resource.Repo

      import ExTeal.Metric.QueryHelpers
      import Ecto.Query, only: [from: 2]

      @doc """
      Performs a count query against the specified schema for the requested
      range.
      """
      @spec count(ExTeal.Metric.ValueRequest.t(), module()) ::
              {:ok, ExTeal.Metric.ValueResult.t()}
      def count(request, module) do
        result = query_for_with_result(__MODULE__, request, module, :count, :id)
        {:ok, result}
      end

      @doc """
      Performs an average query against the specified schema for the requested
      range specified field
      """
      @spec average(ExTeal.Metric.ValueRequest.t(), module(), atom()) ::
              {:ok, ExTeal.Metric.ValueResult.t()}
      def average(request, module, field) do
        result = query_for_with_result(__MODULE__, request, module, :avg, field)
        {:ok, result}
      end

      @doc """
      Performs a max query against the specified schema for the requested
      range specified field
      """
      @spec maximum(ExTeal.Metric.ValueRequest.t(), module(), atom()) ::
              {:ok, ExTeal.Metric.ValueResult.t()}
      def maximum(request, module, field) do
        result = query_for_with_result(__MODULE__, request, module, :max, field)
        {:ok, result}
      end

      @doc """
      Performs a minimum query against the specified schema for the requested
      range specified field
      """
      @spec minimum(ExTeal.Metric.ValueRequest.t(), module(), atom()) ::
              {:ok, ExTeal.Metric.ValueResult.t()}
      def minimum(request, module, field) do
        result = query_for_with_result(__MODULE__, request, module, :min, field)
        {:ok, result}
      end

      @doc """
      Performs a sum query against the specified schema for the requested
      range specified field
      """
      @spec sum(ExTeal.Metric.ValueRequest.t(), module(), atom()) ::
              {:ok, ExTeal.Metric.ValueResult.t()}
      def sum(request, module, field) do
        result = query_for_with_result(__MODULE__, request, module, :sum, field)
        {:ok, result}
      end

      def uri, do: ExTeal.Naming.resource_name(__MODULE__)

      def base_query(queryable) do
        queryable
      end

      def title do
        __MODULE__
        |> ExTeal.Naming.resource_name()
        |> ExTeal.Naming.humanize()
      end

      def component, do: "value-metric"

      def only_on_detail, do: false

      def options,
        do: %{
          ranges: ranges(),
          uri: uri()
        }

      def width, do: "1/3"

      def request(conn, metric \\ nil), do: ValueRequest.from_conn(conn, __MODULE__, metric)

      def prefix, do: nil

      def suffix, do: nil

      def format, do: nil

      defoverridable uri: 0,
                     base_query: 1,
                     title: 0,
                     prefix: 0,
                     suffix: 0,
                     format: 0,
                     only_on_detail: 0
    end
  end
end
