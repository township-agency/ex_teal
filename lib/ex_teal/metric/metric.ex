defmodule ExTeal.Metric do
  @moduledoc """
  Describes the behaviour of a metric with specific callbacks for
  building a base result, calculating the values, applying then and returning
  the result
  """

  @callback date_field() :: atom()

  @callback date_field_type() :: :naive_date_time | :utc_datetime

  defmacro __using__(_opts) do
    quote do
      @behaviour ExTeal.Metric

      use ExTeal.Resource.Repo
      use ExTeal.Metric.Card

      def date_field, do: :inserted_at

      def date_field_type, do: :naive_datetime
    end
  end
end
