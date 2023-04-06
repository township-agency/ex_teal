defmodule ExTeal.GlobalSearch do
  @moduledoc """
  Functionality for searching across a collection of resources using a single search term.
  """

  defstruct conn: nil, resources: [], results: []

  @type t :: %__MODULE__{}

  import Ecto.Query, only: [from: 2]

  alias ExTeal.GlobalSearch
  alias ExTeal.Resource.{Index, Records, Serializer}
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
          |> Records.preload(resource)
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
          r
          |> Serializer.schema_summary(resource)
          |> Map.merge(%{
            resource_name: resource.uri(),
            resource_title: resource.title()
          })
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
