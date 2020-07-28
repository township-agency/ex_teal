defmodule ExTeal.Metric.Request do
  @moduledoc """
  Data Structure for building a Query for a Metric

  Used by the Metric modules to build a data result
  that is turned into a Metric Result
  """

  defstruct [:unit, :uri, :resource_id, :resource, :conn, :timezone, :start_at, :end_at]

  @type t :: %__MODULE__{}

  alias __MODULE__

  @spec from_conn(Plug.Conn.t(), module() | nil) :: Request.t()
  def from_conn(conn, resource \\ nil) do
    struct(__MODULE__, %{
      uri: Map.get(conn.params, "uri"),
      unit: Map.get(conn.params, "unit"),
      start_at: Map.get(conn.params, "start_at"),
      end_at: Map.get(conn.params, "end_at"),
      resource: resource,
      resource_id: Map.get(conn.params, "resource_id"),
      conn: conn
    })
  end
end
