defmodule ExTeal.Resource.Index do
  @moduledoc """
  Behavior for handling index requests for a given resource
  """
  use ExTeal.Resource.Repo

  alias Ecto.Association.ManyToMany
  alias ExTeal.{Field, FieldFilter}
  alias ExTeal.Fields.BelongsTo
  alias ExTeal.Resource.{Fields, Index, Records}

  import Ecto.Query

  @doc """
  Returns the models to be represented by this resource.

  Default implementation is the result of the ExTeal.Resource.Records.records/2
  callback. Usually a module or an `%Ecto.Query{}`.

  The results of this callback are passed to the filter and sort callbacks before the query is executed.

  `handle_index/2` can alternatively return a conn with any response/body.

  Example custom implementation:

      def handle_index(conn, _params) do
        case conn.assigns[:current_user] do
          nil  -> App.Post
          user -> User.own_posts(user)
        end
      end

  In most cases ExTeal.Resource.Records.records/1, filter/4, and sort/4 are the
  better customization hooks.
  """
  @callback handle_index(Plug.Conn.t(), map) :: Plug.Conn.t() | ExTeal.records()

  @doc """
  Returns the models to be represented by this resource via a relationship.

  Default implementation is the result of the ExTeal.Resource.Records.records/2
  callback returning an ecto query with the fields necessary to display the title.

  `handle_related/2` can alternatively return a conn with any response/body.

  Example custom implementation:

      def handle_related(conn, _params) do
        case conn.assigns[:current_user] do
          nil  -> App.Post
          user -> User.own_posts(user)
        end
      end
  """
  @callback handle_related(Plug.Conn.t(), map) :: Plug.Conn.t() | ExTeal.records()

  @doc """
  Defines the search adapter to use while building a search query:

  Defaults to the `ExTeal.Search.SimpleSearch` module
  """
  @callback search_adapter(Ecto.Query.t(), module(), map()) :: Ecto.Query.t()

  @doc """
  Returns the actions available for a resource

  Default implementation is an empty array.
  """
  @callback actions(Plug.Conn.t()) :: [module]

  def call(resource, conn) do
    conn
    |> resource.handle_index(conn.params)
    |> Records.preload(resource)
    |> Index.with_pivot_fields(conn.params, resource)
    |> Index.filter_via_relationships(conn.params)
    |> Index.field_filters(conn, resource)
    |> Index.sort(conn, resource)
    |> Index.search(conn.params, resource)
    |> execute_query(conn, resource, :index)
    |> resource.render_index(resource, conn)
  end

  def query_for_related(resource, conn) do
    conn
    |> resource.handle_related(conn.params)
    |> Records.preload(resource)
    |> Index.query_by_related(conn.params, resource)
    |> Index.search(conn.params, resource)
    |> Index.sort(conn.params, resource)
    |> execute_query(conn, resource, :related)
    |> resource.render_related(resource, conn)
  end

  defmacro __using__(_) do
    quote do
      use ExTeal.Resource.Repo
      use ExTeal.Resource.Records
      use ExTeal.Resource.Fields

      alias ExTeal.Resource.Pagination
      alias ExTeal.Resource.Serializer
      alias ExTeal.Search.SimpleSearch
      alias Phoenix.Controller

      @behaviour ExTeal.Resource.Index

      def handle_index_query(conn, query), do: Pagination.paginate_query(query, conn, __MODULE__)

      def handle_related_query(_conn, query), do: repo().all(query)

      def render_index(models, resource, conn),
        do: Serializer.render_index(models, resource, conn)

      def render_related(models, resource, conn),
        do: Serializer.render_related(models, resource, conn)

      def handle_index(conn, _params), do: records(conn, __MODULE__)

      def handle_related(conn, _params), do: records(conn, __MODULE__)

      def actions(_conn), do: []

      def actions_for(conn) do
        conn
        |> actions()
        |> Enum.map(fn action_module -> action_module.build_for(conn) end)
      end

      def search_adapter(query, resource, params),
        do: SimpleSearch.build(query, resource, params)

      defoverridable(
        actions: 1,
        actions_for: 1,
        handle_index: 2,
        handle_related: 2,
        search_adapter: 3
      )
    end
  end

  def field_filters(query, %{params: %{"field_filters" => filters}} = conn, resource) do
    with {:ok, filters} <- filters |> :base64.decode() |> Jason.decode(),
         false <- Enum.empty?(filters) do
      FieldFilter.query(query, filters, resource, conn)
    else
      _ -> query
    end
  end

  def field_filters(query, _conn, _resource), do: query

  def sort(
        query,
        %{
          params:
            %{
              "order_by" => field,
              "order_by_direction" => dir,
              "relationship_type" => "ManyToMany"
            } = params
        },
        resource
      ) do
    fields = Fields.all_fields(resource)
    field = Enum.find(fields, &(&1.attribute == field))

    case field do
      nil -> sort_by_pivot(query, params, resource)
      _ -> handle_sort(query, field, String.to_existing_atom(field.attribute), dir)
    end
  end

  def sort(query, %{params: %{"order_by" => field, "order_by_direction" => dir}} = conn, resource)
      when not is_nil(field) and not is_nil(dir) do
    new_schema = struct(resource.model(), %{})

    field_struct =
      resource
      |> Fields.index_fields(conn)
      |> Enum.find(&(&1.attribute == field))
      |> then(& &1.type.apply_options_for(&1, new_schema, conn, :index))

    handle_sort(query, field_struct, String.to_existing_atom(field), dir)
  end

  def sort(query, _params, resource) do
    case resource.sortable_by() do
      field when not is_nil(field) -> from(q in query, order_by: ^String.to_existing_atom(field))
      _ -> from(q in query, order_by: ^resource.default_order())
    end
  end

  defp handle_sort(query, %Field{type: BelongsTo} = field, _field_key, dir) do
    handle_sort(query, nil, field.options.belongs_to_key, dir)
  end

  defp handle_sort(query, %Field{virtual: true}, f, "asc") do
    order_by(query, [q], asc: fragment("?", literal(^"#{f}")))
  end

  defp handle_sort(query, %Field{virtual: true}, f, "desc") do
    order_by(query, [q], desc: fragment("?", literal(^"#{f}")))
  end

  defp handle_sort(query, _, field, "asc"), do: order_by(query, [q], asc: field(q, ^field))
  defp handle_sort(query, _, field, "desc"), do: order_by(query, [q], desc: field(q, ^field))
  defp handle_sort(query, _, _, _), do: query

  defp sort_by_pivot(query, params, _resource) do
    with {:ok, field} <- Map.fetch(params, "order_by"),
         {:ok, dir} <- Map.fetch(params, "order_by_direction"),
         field_atom <- String.to_existing_atom(field),
         dir_atom <- String.to_existing_atom(dir) do
      order_by(query, [q, x], [{^dir_atom, field(x, ^field_atom)}])
    end
  end

  def search(query, params, resource) do
    case Map.get(params, "search") do
      nil ->
        query

      "" ->
        query

      _ ->
        resource.search_adapter(query, resource, params)
    end
  end

  def query_by_related(query, %{"first" => "true", "current" => id}, _resource)
      when id != "" do
    query
    |> limit(1)
    |> where([q], q.id == ^id)
  end

  def query_by_related(query, _, _), do: query

  def with_pivot_fields(
        query,
        %{
          "via_resource" => resource_name,
          "via_resource_id" => resource_id,
          "via_relationship" => rel_name,
          "relationship_type" => "ManyToMany"
        },
        _resource
      ) do
    with {:ok, resource} <- ExTeal.resource_for(resource_name),
         {:ok, resource_assoc} <- schema_assoc_for(resource, rel_name) do
      resource_field =
        Enum.find(resource.fields(), &(&1.field == String.to_existing_atom(rel_name)))

      pivot_query(query, resource_assoc, resource_id, resource_field)
    end
  end

  def with_pivot_fields(query, _params, _resource) do
    query
  end

  def filter_via_relationships(query, %{
        "relationship_type" => "ManyToMany"
      }) do
    query
  end

  def filter_via_relationships(
        query,
        %{
          "via_resource" => resource_name,
          "via_resource_id" => resource_id,
          "via_relationship" => rel_name
        }
      )
      when resource_name != "" and resource_id != "" and rel_name != "" do
    with {:ok, resource} <- ExTeal.resource_for(resource_name),
         {:ok, relationship} <- schema_assoc_for(resource, rel_name) do
      reversed_query(relationship, query, resource_id, resource)
    end
  end

  def filter_via_relationships(query, _params), do: query

  def reversed_query(%Ecto.Association.HasThrough{} = rel, query, resource_id, related_resource) do
    related_schema = related_resource.record(nil, resource_id)
    related = repo().preload(related_schema, rel.field)
    ids = related |> Map.get(rel.field) |> Enum.map(& &1.id)
    from(q in query, where: q.id in ^ids)
  end

  def reversed_query(relationship, query, resource_id, _related_resource) do
    from(query, where: ^[{relationship.related_key, resource_id}])
  end

  defp schema_assoc_for(resource, rel_name) do
    associations = resource.model().__schema__(:associations)
    rel = String.to_existing_atom(rel_name)

    case Enum.member?(associations, rel) do
      false ->
        {:error, :not_found}

      true ->
        {:ok, resource.model().__schema__(:association, rel)}
    end
  end

  defp pivot_query(
         query,
         %ManyToMany{join_through: join_through} = assoc,
         resource_id,
         many_to_many_field
       )
       when is_bitstring(join_through) do
    query
    |> join_pivot_and_filter(assoc, resource_id)
    |> customize_many_to_many_query(many_to_many_field, assoc, resource_id)
  end

  defp pivot_query(query, assoc, resource_id, many_to_many_field) do
    query
    |> join_pivot_and_filter(assoc, resource_id)
    |> customize_many_to_many_query(many_to_many_field, assoc, resource_id)
  end

  defp customize_many_to_many_query(
         query,
         %Field{private_options: %{index_query_fn: index_fn}},
         assoc,
         resource_id
       ) do
    index_fn.(query, assoc, resource_id)
  end

  defp customize_many_to_many_query(query, _field, %ManyToMany{join_through: assoc}, _)
       when is_bitstring(assoc),
       do: query

  defp customize_many_to_many_query(query, _, _, _),
    do: select(query, [q, x], %{_row: q, _pivot: x, pivot: true})

  defp join_pivot_and_filter(query, assoc, resource_id) do
    [{rel_1, _rel_2}, {pivot_id, id}] = assoc.join_keys

    from(
      q in query,
      left_join: x in ^assoc.join_through,
      on: field(x, ^pivot_id) == field(q, ^id),
      where: field(x, ^rel_1) == ^String.to_integer(resource_id)
    )
  end

  @doc false
  def execute_query(%Plug.Conn{} = conn, _conn, _resource, _type), do: conn
  def execute_query(results, _conn, _resource, _type) when is_list(results), do: results

  def execute_query(query, conn, resource, :related),
    do: resource.handle_related_query(conn, query)

  def execute_query(query, conn, resource, :index), do: resource.handle_index_query(conn, query)
end
