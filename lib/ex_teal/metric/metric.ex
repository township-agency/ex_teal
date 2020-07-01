defmodule ExTeal.Metric do
  @moduledoc """
  Describes the behaviour of a metric with specific callbacks for
  building a base result, calculating the values, applying then and returning
  the result
  """

  @doc """
  Calculate the data for a specific metric.
  """
  @callback calculate(ExTeal.Metric.Request.t()) :: map()

  defmacro __using__(_opts) do
    quote do
      @behaviour ExTeal.Metric

      use ExTeal.Resource.Repo
      use ExTeal.Metric.Card
    end
  end
end
