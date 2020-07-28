defmodule ExTeal.Dashboard do
  @moduledoc """
  Module used to represent a dashboard which contains a grid of metrics, this will one day be extendable to include
  plugin or custom cards in the future.
  """

  alias ExTeal.Card

  @type range :: %{
          label: String.t(),
          unit: String.t(),
          value: integer()
        }

  @callback title() :: String.t()

  @callback uri() :: String.t()

  @callback ranges() :: [range()]

  @callback default_range() :: range()

  @doc """
  Return the modules that represent cards on the
  dashboard.
  """
  @callback cards(Plug.Conn.t()) :: [module()]

  defmacro __using__(_) do
    quote do
      @behaviour ExTeal.Dashboard
      alias ExTeal.Dashboard
      alias ExTeal.Resource.Model

      @implied_title Model.title_from_resource(__MODULE__)
      @implied_uri Phoenix.Naming.underscore(@implied_title)

      def title do
        @implied_title
        |> Inflex.singularize()
      end

      def uri do
        @implied_uri
        |> Inflex.underscore()
        |> String.replace(" ", "_")
      end

      def cards(_conn), do: []

      def ranges, do: Dashboard.default_ranges()

      def default_range, do: %{label: "24H", unit: "hour", value: 24}

      defoverridable title: 0, cards: 1, uri: 0, ranges: 0, default_range: 0
    end
  end

  def map_to_json(modules) do
    modules
    |> Enum.map(fn module ->
      %{
        title: module.title(),
        uri: module.uri(),
        ranges: module.ranges(),
        default_range: module.default_range()
      }
    end)
  end

  def cards_to_json(dashboard_module, conn) do
    cards =
      conn
      |> dashboard_module.cards()
      |> Enum.map(&Card.to_struct(&1, conn))

    %{cards: cards}
  end

  @spec default_ranges() :: [range()]
  def default_ranges,
    do: [
      %{label: "60m", unit: "minute", value: 60},
      %{label: "24H", unit: "hour", value: 24},
      %{label: "7D", unit: "day", value: 7},
      %{label: "14D", unit: "day", value: 14},
      %{label: "4W", unit: "week", value: 4},
      %{label: "3M", unit: "month", value: 3},
      %{label: "6M", unit: "month", value: 6},
      %{label: "1Y", unit: "month", value: 12},
      %{label: "3Y", unit: "year", value: 3}
    ]
end
