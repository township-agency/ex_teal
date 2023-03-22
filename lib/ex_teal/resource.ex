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
  If you would like to separate resources into different sidebar groups, you can
  override the `nav_group/1` function on the resource.
  """
  @callback nav_group(Plug.Conn.t()) :: String.t() | nil

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
      use ExTeal.Resource.Export
      use ExTeal.Resource.Policy

      import ExTeal.FieldVisibility
      import ExTeal.Field, only: [get: 2]

      def hide_from_nav, do: false

      def nav_group(_), do: nil

      def sortable_by, do: nil

      def default_order, do: [asc: :id]

      def cards(_conn), do: []

      def skip_sanitize, do: false

      defoverridable(
        hide_from_nav: 0,
        nav_group: 1,
        sortable_by: 0,
        default_order: 0,
        cards: 1,
        skip_sanitize: 0
      )
    end
  end

  def map_to_json(resources, conn) do
    Enum.map(resources, &to_json(&1, conn))
  end

  def to_json(resource, conn) do
    singular =
      resource.title() |> Inflex.underscore() |> Naming.humanize() |> Inflex.singularize()

    %{
      title: resource.title(),
      singular: singular,
      group: resource.nav_group(conn),
      uri: resource.uri(),
      hidden: resource.hide_from_nav(),
      skip_sanitize: resource.skip_sanitize(),
      searchable: !Enum.empty?(resource.search()),
      can_create_any: resource.policy().create_any?(conn),
      can_view_any: resource.policy().view_any?(conn),
      can_update_any: resource.policy().update_any?(conn),
      can_delete_any: resource.policy().delete_any?(conn),
      default_filters: resource.default_filters()
    }
  end
end
