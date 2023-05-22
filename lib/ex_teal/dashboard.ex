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

  @doc """
  Unique URI that allows the dashboard to look up cards.  Should be url safe.
  """
  @callback uri() :: String.t()

  @doc """
  Return the modules that represent cards on the
  dashboard.
  """
  @callback cards(Plug.Conn.t()) :: [module()]

  @doc """
  Show or Hide a dashboard based on the current connection. Defaults to true
  """
  @callback display?(Plug.Conn.t()) :: boolean()

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

      def display?(_conn), do: true

      defoverridable title: 0, cards: 1, uri: 0, display?: 1
    end
  end

  def map_to_json(modules) do
    modules
    |> Enum.map(fn module ->
      %{
        title: module.title(),
        uri: module.uri()
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
end
