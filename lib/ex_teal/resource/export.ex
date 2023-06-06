defmodule ExTeal.Resource.Export do
  @moduledoc """
  Adds functionality for exporting a stream of records
  as a csv file.
  """

  import Ecto.Query
  import Plug.Conn
  alias ExTeal.Resource.{Index, Records}
  alias Plug.Conn

  @doc """
  Modify the query for a csv result
  """
  @callback handle_export_query(Ecto.Query.t(), Conn.t()) :: Ecto.Query.t()

  @doc """
  The fields to export from the resource
  """
  @callback export_fields :: [atom()]

  @doc """
  Parse a row into a CSV Encodeable list of fields

  Useful for modifying database columns into serializeable strings
  before the row is passed to CSV.encode/2
  """
  @callback parse_export_row(db_record :: map(), fields :: [atom()]) :: [any()]

  @doc """
  Define an override to the default parser, as defined in the `ex_teal` config

  Expects the parser to have a dump_to_stream/1 function that accepts a stream
  of rows and returns a stream of rows.
  """
  @callback export_module() :: module()

  defmacro __using__(_) do
    quote do
      use ExTeal.Resource.Repo
      use ExTeal.Resource.Record
      alias ExTeal.Resource.Export
      @behaviour ExTeal.Resource.Export

      def handle_export_query(query, _conn), do: Export.default_export_query(query, __MODULE__)

      def export_fields, do: Export.default_export_fields(__MODULE__)

      def parse_export_row(record, fields), do: Export.default_parse(record, fields)

      def export_module do
        case Application.fetch_env(:ex_teal, :export_module) do
          {:ok, module} -> module
          :error -> nil
        end
      end

      defoverridable handle_export_query: 2,
                     export_fields: 0,
                     parse_export_row: 2,
                     export_module: 0
    end
  end

  @doc """
  Build a streamed csv and chunk the results as a response.

  Uses the resource's querying functionality (filtering, searching, sorting)
  to return only the resources the user has selected.
  """
  @spec stream(module, Conn.t()) :: Conn.t()
  def stream(resource, conn) do
    conn =
      conn
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=export-#{resource.uri()}.csv"
      )
      |> put_resp_content_type("text/csv")
      |> send_chunked(200)

    {:ok, conn} =
      resource.repo().transaction(fn ->
        resource
        |> stream_response_to_conn(conn)
        |> Enum.reduce_while(conn, &chunk_or_halt/2)
      end)

    conn
  end

  @doc """
  Returns a list of all fields on the schema
  for export
  """
  @spec default_export_fields(module()) :: [atom()]
  def default_export_fields(resource) do
    resource.model().__schema__(:fields)
  end

  defp stream_response_to_conn(resource, conn) do
    fields = resource.export_fields()
    repo = resource.repo()
    header_stream = fields_to_header(fields)

    parser = resource.export_module()

    resource_stream =
      resource
      |> exportable_query(conn)
      |> repo.stream()
      |> Stream.map(&resource.parse_export_row(&1, fields))

    stream = Stream.concat([[header_stream], resource_stream])

    parser.dump_to_stream(stream)
  end

  defp chunk_or_halt(data, conn) do
    case chunk(conn, data) do
      {:ok, conn} ->
        {:cont, conn}

      {:error, :closed} ->
        {:halt, conn}
    end
  end

  @doc """
  Returns the query with a select that parses all the
  fields into a map instead of the struct
  """
  @spec default_export_query(Ecto.Query.t(), module) :: Ecto.Query.t()
  def default_export_query(query, resource) do
    fields = resource.export_fields()
    select(query, [q], map(q, ^fields))
  end

  @doc """
  Turns a record represented as a map and a list of atoms representing
  the ordered fields in the CSV into a list of values in the same order
  as the list of fields
  """
  @spec default_parse(map(), [atom()]) :: [any()]
  def default_parse(record, fields) do
    Enum.map(fields, &Map.get(record, &1))
  end

  @spec exportable_query(module, Conn.t()) :: Ecto.Queryable.t()
  defp exportable_query(resource, %Conn{params: %{"resources" => "all"} = params} = conn) do
    conn
    |> resource.handle_index(params)
    |> Records.preload(resource)
    |> Index.filter_via_relationships(params)
    |> Index.field_filters(conn, resource)
    |> Index.sort(params, resource)
    |> Index.search(params, resource)
    |> resource.handle_export_query(params)
    |> exclude(:preload)
  end

  defp exportable_query(resource, %Conn{params: %{"resources" => ids} = params} = conn) do
    ids = ids |> String.split(",") |> Enum.map(&String.to_integer/1)

    conn
    |> resource.handle_index(params)
    |> Records.preload(resource)
    |> Index.sort(params, resource)
    |> where([r], r.id in ^ids)
    |> resource.handle_export_query(params)
    |> exclude(:preload)
  end

  defp fields_to_header(fields), do: Enum.map(fields, &Atom.to_string/1)

  @doc """
  Convert map atom keys to strings
  """
  def stringify_keys(nil), do: nil

  def stringify_keys(%{} = map) do
    Enum.into(map, %{}, fn {k, v} ->
      {Atom.to_string(k), v}
    end)
  end

  def stringify_keys(not_a_map) do
    not_a_map
  end
end
