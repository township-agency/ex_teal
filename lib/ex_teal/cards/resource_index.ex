defmodule ExTeal.Cards.ResourceIndex do
  @moduledoc """
  Sometimes you need a summary table that doesn't easily fit into a single resource.
  Sometimes you need a collection of summary tables on a dashboard.

  This is where the ResourceIndex comes in. It's a way to show a resource index table
  on a dashboard.
  """

  @doc """
  The teal resource used for the table
  """
  @callback resource() :: module

  defmacro(__using__(_opts)) do
    quote do
      @behaviour ExTeal.Cards.ResourceIndex
      use ExTeal.Card

      @impl true
      def component, do: "cards-resource-index"

      @impl true
      def options(_conn),
        do: %{
          resource_uri: resource().uri(),
          title: resource().title()
        }
    end
  end
end
