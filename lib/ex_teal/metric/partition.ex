defmodule ExTeal.Metric.Partition do
  @moduledoc """
  Partition metrics displays a pie chart of values.
  """
  import Ecto.Query

  @type result :: %{label: any(), value: float() | integer()}

  @callback calculate(ExTeal.Metric.Request.t()) :: [result()]

  @doc """
  Often, the column values that divide your partition metrics into
  groups will be simple keys, and not something that is human readable.
  Or, if you are displaying a partition metric grouped by a column that is a
  boolean, Teal will display labels as "false" and "true".  For this reason, Teal
  provides the `label_for/1` callback that can be overriden on a partition metric
  to provide a custom label for each value.

      @impl true
      def label_for(false), do: "User"
      def label_for(true), do: "Admin"

  It's also useful for handling null values:

      @impl true
      def label_for(null), do: "None"
      def label_for(key), do: String.capitalize(key)

  """
  @callback label_for(String.t()) :: String.t()

  defmacro __using__(_opts) do
    quote do
      @behaviour ExTeal.Metric.Partition
      use ExTeal.Metric
      alias Ecto.Query
      alias ExTeal.Metric.{Partition, Request, Result}

      def component, do: "partition-metric"

      @doc """
      Returns a partition result showing the segments of a count aggregate.
      """
      @spec count(
              query :: Ecto.Queryable.t(),
              group_by :: atom(),
              column :: atom() | nil
            ) :: Partition.result()
      def count(query, group_by, column \\ :id) do
        Partition.aggregate(__MODULE__, query, :count, group_by, column)
      end

      @doc """
      Returns a partition result showing the segments of an average aggregate.
      """
      @spec average(
              query :: Ecto.Queryable.t(),
              group_by :: atom(),
              column :: atom()
            ) :: Partition.result()
      def average(query, group_by, column) do
        Partition.aggregate(__MODULE__, query, :avg, group_by, column)
      end

      @doc """
      Returns a partition result showing the segments of an maximum aggregate.
      """
      @spec maximum(
              query :: Ecto.Queryable.t(),
              group_by :: atom(),
              column :: atom()
            ) :: Partition.result()
      def maximum(query, group_by, column) do
        Partition.aggregate(__MODULE__, query, :max, group_by, column)
      end

      @doc """
      Returns a partition result showing the segments of an minimum aggregate.
      """
      @spec minimum(
              query :: Ecto.Queryable.t(),
              group_by :: atom(),
              column :: atom()
            ) :: Partition.result()
      def minimum(query, group_by, column) do
        Partition.aggregate(__MODULE__, query, :min, group_by, column)
      end

      @doc """
      Returns a partition result showing the segments of an sum aggregate.
      """
      @spec sum(
              query :: Ecto.Queryable.t(),
              group_by :: atom(),
              column :: atom()
            ) :: Partition.result()
      def sum(query, group_by, column) do
        Partition.aggregate(__MODULE__, query, :sum, group_by, column)
      end

      def label_for(true), do: "true"
      def label_for(false), do: "false"
      def label_for(k), do: k

      def order_by(query, grouper), do: Partition.default_order_by(query, grouper)

      defoverridable label_for: 1, order_by: 2
    end
  end

  @spec aggregate(
          metric :: module(),
          query :: Ecto.Queryable.t(),
          aggregate :: atom(),
          group_by :: atom(),
          column :: atom()
        ) :: [ExTeal.Metric.Partition.result()]
  def aggregate(metric, query, aggregate, grouper, column) do
    query
    |> group_by([x], field(x, ^grouper))
    |> select([x], %{
      key: field(x, ^grouper)
    })
    |> aggregate_select(aggregate, column)
    |> metric.order_by(grouper)
    |> metric.repo().all()
    |> to_result(metric)
  end

  @doc """
  By default sort the partition results by the group field
  """
  def default_order_by(query, grouper) do
    order_by(query, [q], asc_nulls_last: field(q, ^grouper))
  end

  defp aggregate_select(query, :count, column) do
    select_merge(query, [x], %{aggregate: count(field(x, ^column))})
  end

  defp aggregate_select(query, :sum, column) do
    select_merge(query, [x], %{aggregate: sum(field(x, ^column))})
  end

  defp aggregate_select(query, :min, column) do
    select_merge(query, [x], %{aggregate: min(field(x, ^column))})
  end

  defp aggregate_select(query, :max, column) do
    select_merge(query, [x], %{aggregate: max(field(x, ^column))})
  end

  defp to_result(result, metric_module) do
    Enum.map(result, fn %{aggregate: v, key: k} ->
      %{value: v, label: metric_module.label_for(k)}
    end)
  end
end
