defmodule ExTeal.Resource do
  @type params :: map()

  @moduledoc """
  When used, includes all aspects of the functionality required to
  manage the resource.

  Example usage in a ExTeal Resource:

      defmodule ExampleWeb.ExTeal.BlogResource do
        use ExTeal.Resource

        alias Example.Content.Blog

        def resource, do: Blog

        def title, do: "blog"
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

  @type pivot_resource :: %{_pivot: struct(), _row: struct(), pivot: true}

  @type indexed_resource :: struct() | pivot_resource()

  @doc """
  Override the detail or edit link for a resource on the resource index.

  When defining this callback, be aware that resources referenced by a many to many relationship
  will also call this function when rendering the index of that many to many.
  """
  @callback navigate_to(:detail | :edit, Plug.Conn.t(), indexed_resource()) :: %{
              resource_name: String.t(),
              resource_id: String.t()
            }

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

      def navigate_to(_, _conn, %{pivot: true, _row: row}),
        do: %{resource_name: uri(), resource_id: row.id}

      def navigate_to(_, _conn, schema), do: %{resource_name: uri(), resource_id: schema.id}

      defoverridable(
        hide_from_nav: 0,
        nav_group: 1,
        sortable_by: 0,
        default_order: 0,
        cards: 1,
        skip_sanitize: 0,
        navigate_to: 3
      )
    end
  end

  def map_to_json(resources, conn) do
    Enum.map(resources, &to_json(&1, conn))
  end

  def to_json(resource, conn) do
    %{
      title: resource.title(),
      singular: resource.singular_title(),
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
