defmodule ExTeal.Metric.Card do
  @moduledoc """
  Common display logic for the card that displays a metric.
  """

  @doc """
  Explicitly set the uri used to fetch the details of a card.
  """
  @callback uri() :: String.t()

  @doc """
  Set the title displayed at the top of the card, defaults
  to a humanized title of the module
  """
  @callback title :: String.t()

  @doc """
  Set the width of card that displays the metric.  Defaults to 1/3.
  1/3 and full are the only allowed values
  """
  @callback width :: String.t()

  @doc """
  Only display the metric on the detail page of a specific resource.
  """
  @callback only_on_detail(Plug.Conn.t()) :: boolean()

  @doc """
  Only display the metric on the index page of a specific resource.
  """
  @callback only_on_index(Plug.Conn.t()) :: boolean()

  @doc """
  A string to prepend to any displayed value on the metric card. For example: `$`
  """
  @callback prefix() :: String.t()

  @doc """
  A string to appended to any displayed value on the metric card.  For example: `°`
  """
  @callback suffix() :: String.t()

  @doc """
  A string representing how a value is formatted before being displayed by the
  [numbro](https://numbrojs.com/) library.  Defaults to `(0[.]00a)`
  """
  @callback format() :: String.t()

  @doc """
  The name of the component to mount in the ux responsible for rendering
  the content
  """
  @callback component() :: String.t()

  defmacro __using__(_opts) do
    quote do
      @behaviour ExTeal.Metric.Card

      def uri, do: ExTeal.Naming.resource_name(__MODULE__)

      def title do
        __MODULE__
        |> ExTeal.Naming.resource_name()
        |> ExTeal.Naming.humanize()
      end

      def width, do: "1/3"

      def only_on_index(_conn), do: false

      def only_on_detail(_conn), do: false

      def prefix, do: nil

      def suffix, do: nil

      def format, do: nil

      def options, do: %{}

      def component, do: "empty-metric"

      defoverridable uri: 0,
                     title: 0,
                     width: 0,
                     only_on_detail: 1,
                     only_on_index: 1,
                     prefix: 0,
                     suffix: 0,
                     format: 0,
                     component: 0,
                     options: 0
    end
  end
end
