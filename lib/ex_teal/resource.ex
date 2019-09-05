defmodule ExTeal.Resource do
  @type params :: map()

  alias Phoenix.Naming

  @moduledoc """
  When used, includes all aspects of the functionality required to
  manage the resource.

  Example usage in a ExTeal Resource:

      defmodule ExampleWeb.ExTeal.BlogResource do
        use ExTeal.Resource

        alias Example.Content.Blog
        alias ExTeal.Fields.{ID, F}
        def resource, do: Blog

        def title, do: "blog"

        def fields, do: [

        ]
      end
  """

  @callback hide_from_nav() :: boolean()

  @callback sortable_by() :: String.t() | nil

  @callback cards(Plug.Conn.t()) :: [module]

  defmacro __using__(_opts) do
    quote do
      @behaviour ExTeal.Resource
      use ExTeal.Resource.Create
      use ExTeal.Resource.Index
      use ExTeal.Resource.Show
      use ExTeal.Resource.Update
      use ExTeal.Resource.Delete
      use ExTeal.Resource.Query

      import ExTeal.FieldVisibility

      def hide_from_nav, do: false

      def sortable_by, do: nil

      def cards(_conn), do: []

      defoverridable(hide_from_nav: 0, sortable_by: 0, cards: 1)
    end
  end

  def map_to_json(resources) do
    Enum.map(resources, &to_json/1)
  end

  def to_json(resource) do
    singular = resource.title |> Inflex.underscore() |> Naming.humanize() |> Inflex.singularize()

    %{
      title: resource.title(),
      singular: singular,
      uri: resource.uri(),
      hidden: resource.hide_from_nav(),
      searchable: !Enum.empty?(resource.search())
    }
  end
end
