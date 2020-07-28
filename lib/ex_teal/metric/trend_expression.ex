defmodule ExTeal.Metric.TrendExpression do
  @moduledoc """
  Behaviour for trend expression builders
  """

  @doc """
  Use database specifc syntax to build an expression for both selecting
  and grouping by a given unit of time.  The function uses `select_merge` to
  build a date_result value assuming that a previous select has been used to
  generate a query for the aggregate.
  """
  @callback generate(
              query :: Ecto.Queryable.t(),
              metric :: module(),
              timezone :: String.t(),
              unit :: String.t()
            ) ::
              Ecto.Queryable.t()

  defmacro __using__(_opts) do
    quote do
      @behaviour ExTeal.Metric.TrendExpression
      import Ecto.Query
      import ExTeal.Metric.TrendExpression, only: [fetch_offset: 1]
    end
  end

  use Timex

  @type valid_timezone :: String.t() | integer() | :utc | :local

  @spec fetch_offset(String.t()) :: float()
  def fetch_offset(timezone) do
    seconds =
      timezone
      |> Timezone.get(Timex.now())
      |> Timezone.total_offset()

    seconds / 3_600
  end
end
