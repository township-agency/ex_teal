defmodule ExTeal.GlobalSearch do
  @moduledoc """
  Functionality for searching across a collection of resources using a single search term.
  """

  defstruct conn: nil, resources: [], results: []

  @type t :: %__MODULE__{}

  import Ecto.Query, only: [from: 2]

  alias ExTeal.GlobalSearch
  alias ExTeal.Resource.{Index, Serializer}
  alias Plug.Conn

  @spec new(Conn.t(), [module]) :: GlobalSearch.t()
  def new(conn, resources) do
    %__MODULE__{conn: conn, resources: resources}
  end

  def run(%GlobalSearch{conn: %Conn{params: params} = conn, resources: resources} = gs) do
    results =
      Enum.map(resources, fn resource ->
        result =
          conn
          |> resource.handle_index(params)
          |> Index.search(params, resource)
          |> prepare_for_search(resource)
          |> resource.repo().all()

        {resource, result}
      end)

    Map.put(gs, :results, results)
  end

  def run(search), do: search

  def render(%GlobalSearch{results: results, conn: conn}) do
    results =
      results
      |> Enum.map(fn {resource, result} ->
        Enum.map(result, fn r ->
          %{
            title: resource.title_for_schema(r),
            subtitle: resource.subtitle_for_schema(r),
            thumbnail: resource.thumbnail_for_schema(r),
            resourceName: resource.uri(),
            resourceId: r.id,
            resourceTitle: resource.title()
          }
        end)
      end)
      |> Enum.concat()

    {:ok, body} = Jason.encode(%{results: results})
    Serializer.as_json(conn, body, 200)
  end

  defp prepare_for_search(query, _resource) do
    from(q in query, limit: 5)
  end
end
