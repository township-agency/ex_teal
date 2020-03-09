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

  @type orderable_key ::
          :asc | :asc_nulls_first | :asc_nulls_last | :desc | :desc_nulls_first | :desc_nulls_last

  @type orderable_option :: {orderable_key, atom()}

  @type attributes :: map()

  @type id :: String.t() | integer()

  @type record :: struct()

  @type records :: [record()]

  @type t :: module()

  @type validation_errors :: Ecto.Changeset.t() | keyword()

  @doc """
  Hide the Resource from the sidenav in the user interface, defaults to false.
  """
  @callback hide_from_nav() :: boolean()

  @doc """
  Specifies the field to use as the basis for a drag and drop interface for the collection.
  """
  @callback sortable_by() :: String.t() | nil

  @doc """
  Allows skipping sanitize for all fields on a resource
  """
  @callback skip_sanitize() :: boolean() | nil

  @doc """
  Provide a list of action cards to render them above the resource index
  """
  @callback cards(Plug.Conn.t()) :: [module]

  @doc """
  Override the default ordering of the index.
  """
  @callback default_order() :: [orderable_option]

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
      import ExTeal.Field, only: [get: 2]

      def hide_from_nav, do: false

      def sortable_by, do: nil

      def default_order, do: [asc: :id]

      def cards(_conn), do: []

      def skip_sanitize, do: false

      defoverridable(
        hide_from_nav: 0,
        sortable_by: 0,
        default_order: 0,
        cards: 1,
        skip_sanitize: 0
      )
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
      skip_sanitize: resource.skip_sanitize(),
      searchable: !Enum.empty?(resource.search())
    }
  end
end
