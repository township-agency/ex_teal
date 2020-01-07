defmodule ExTeal.Resource.Index do
  @moduledoc """
  Behavior for handling index requests for a given resource
  """

  alias Ecto.Association.ManyToMany
  alias ExTeal.Field
  alias ExTeal.Fields.BelongsTo
  alias ExTeal.Filter
  alias ExTeal.Resource.Index

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
  Returns the filters available for a resource.

  Default implementation is an empty array.

  `filters/1` can alternatively use the conn to guard certain filters:

      def filters(conn) do
        case conn.assigns[:current_user] do
          nil -> []
          user -> [MyPostsFilter]
        end
      end
  """
  @callback filters(Plug.Conn.t()) :: []

  @doc """
  Returns the actions available for a resource

  Default implementation is an empty array.
  """
  @callback actions(Plug.Conn.t()) :: [module]

  def call(resource, conn) do
    conn
    |> resource.handle_index(conn.params)
    |> Index.with_pivot_fields(conn.params, resource)
    |> Index.filter_via_relationships(conn.params)
    |> Index.filter(conn, resource)
    |> Index.sort(conn.params, resource)
    |> Index.search(conn.params, resource)
    |> execute_query(conn, resource, :index)
    |> resource.render_index(resource, conn)
  end

  def query_for_related(resource, conn) do
    conn
    |> resource.handle_related(conn.params)
    |> Index.search(conn.params, resource)
    |> Index.query_by_related(conn.params, resource)
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

      def filters(_conn), do: []

      def filters_for(conn) do
        conn
        |> filters()
        |> Enum.map(fn filter_module -> filter_module.build_for(conn) end)
      end

      def actions(_conn), do: []

      def actions_for(conn) do
        conn
        |> actions()
        |> Enum.map(fn action_module -> action_module.build_for(conn) end)
      end

      defoverridable(
        filters: 1,
        filters_for: 1,
        actions: 1,
        actions_for: 1,
        handle_index: 2,
        handle_related: 2
      )
    end
  end

  def filter(query, %Plug.Conn{params: %{"filters" => filter}} = conn, resource)
      when not is_nil(filter) do
    resource_filters = resource.filters(conn)

    with {:ok, filters} <- filter |> :base64.decode() |> Jason.decode(),
         false <- Enum.empty?(filters) do
      Enum.reduce(filters, query, fn filter, acc ->
        apply_filter(filter, acc, conn, resource_filters)
      end)
    else
      {:error, _} -> query
      true -> query
    end
  end

  def filter(query, _conn, _resource), do: query

  defp apply_filter(filter, query, conn, resource_filters) do
    filter_module = Filter.filter_for_key(resource_filters, Map.get(filter, "key"))

    case filter_module do
      nil ->
        query

      module ->
        module.apply_query(conn, query, Map.get(filter, "value"))
    end
  end

  @doc false
  def sort(
        query,
        %{"order_by" => field, "order_by_direction" => dir, "via_relationship" => field},
        _resource
      )
      when not is_nil(field) and not is_nil(dir) do
    handle_sort(query, nil, :id, dir)
  end

  def sort(
        query,
        %{"order_by" => field, "order_by_direction" => dir, "relationship_type" => "ManyToMany"} =
          params,
        resource
      ) do
    field = Enum.find(resource.fields(), &(&1.attribute == field))

    case field do
      nil -> sort_by_pivot(query, params, resource)
      _ -> handle_sort(query, field, String.to_existing_atom(field), dir)
    end
  end

  def sort(query, %{"order_by" => field, "order_by_direction" => dir}, resource)
      when not is_nil(field) and not is_nil(dir) do
    field_struct = Enum.find(resource.fields(), &(&1.attribute == field))
    handle_sort(query, field_struct, String.to_existing_atom(field), dir)
  end

  def sort(query, _params, resource) do
    case resource.sortable_by() do
      nil -> from(q in query, order_by: :id)
      field -> from(q in query, order_by: ^String.to_existing_atom(field))
    end
  end

  defp handle_sort(query, %Field{type: BelongsTo}, field, dir) do
    handle_sort(query, nil, String.to_existing_atom("#{Atom.to_string(field)}_id"), dir)
  end

  defp handle_sort(query, _, field, "asc"), do: from(query, order_by: ^[{:asc, field}])
  defp handle_sort(query, _, field, "desc"), do: from(query, order_by: ^[{:desc, field}])
  defp handle_sort(query, _, _, _), do: query

  defp sort_by_pivot(query, params, _resource) do
    with {:ok, field} <- Map.fetch(params, "order_by"),
         {:ok, dir} <- Map.fetch(params, "order_by_direction"),
         field_atom <- String.to_existing_atom(field),
         dir_atom <- String.to_existing_atom(dir) do
      order_by(query, [q, x], [{^dir_atom, field(x, ^field_atom)}])
    end
  end

  def search(query, %{"search" => term}, resource) when not is_nil(term) and term != "" do
    dynamic = false

    dynamic =
      Enum.reduce(resource.search(), dynamic, fn field, dynamic ->
        attempt_to_search_by(field, dynamic, resource, term)
      end)

    from(query, where: ^dynamic)
  end

  def search(query, _params, _resource), do: query

  defp attempt_to_search_by(f, dynamic, _resource, term) do
    dynamic([q], ilike(field(q, ^f), ^"%#{term}%") or ^dynamic)
  end

  def query_by_related(query, %{"first" => "true", "current" => term}, _resource)
      when term != "" do
    query
    |> limit(1)
    |> where([q], q.id == ^term)
  end

  # def query_by_related(query, %{"current" => term, "search" => search}, _resource)
  #     when term != "" and search == "" do
  #   where(query, [q], q.id == ^term)
  # end

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
      pivot_query(query, resource_assoc, resource_id)
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

  def filter_via_relationships(query, %{
        "via_resource" => resource_name,
        "via_resource_id" => resource_id,
        "via_relationship" => rel_name
      }) do
    with {:ok, resource} <- ExTeal.resource_for(resource_name),
         {:ok, relationship} <- schema_assoc_for(resource, rel_name) do
      from(query, where: ^[{relationship.related_key, resource_id}])
    end
  end

  def filter_via_relationships(query, _params), do: query

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

  defp pivot_query(query, %ManyToMany{join_through: join_through} = assoc, resource_id)
       when is_bitstring(join_through) do
    join_pivot_and_filter(query, assoc, resource_id)
  end

  defp pivot_query(query, assoc, resource_id) do
    query
    |> join_pivot_and_filter(assoc, resource_id)
    |> select([q, x], %{_row: q, _pivot: x, pivot: true})
  end

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
