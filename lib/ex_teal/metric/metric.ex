defmodule ExTeal.Metric do
  @moduledoc """
  Describes the behaviour of a metric with specific callbacks for
  building a base result, calculating the values, applying then and returning
  the result
  """

  @callback date_field() :: :naive_date_time | :utc_datetime
  @callback date_field_type() :: :naive_date_time | :utc_datetime
  @callback multiple_results() :: boolean()

  defmacro __using__(_) do
    quote do
      use ExTeal.Resource.Repo
      use ExTeal.Metric.Card
      @behaviour ExTeal.Metric

      def date_field, do: :inserted_at

      def date_field_type, do: :naive_datetime

      def multiple_results, do: false

      defoverridable(multiple_results: 0, date_field_type: 0, date_field: 0)
    end
  end
end
