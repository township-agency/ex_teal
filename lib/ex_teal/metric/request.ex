defmodule ExTeal.Metric.Request do
  @moduledoc """
  Data Structure for building a Value Query

  Used by the Metric Value module to build a
  Value Result
  """

  defstruct [:range, :uri, :resource_id, :resource]

  @type t :: %__MODULE__{}

  def from_conn(conn, metric, resource) do
    struct(__MODULE__, %{
      uri: Map.get(conn.params, "uri"),
      range: range_for(metric, Map.get(conn.params, "range")),
      resource: resource,
      resource_id: Map.get(conn.params, "resource_id")
    })
  end

  def range_for(metric, nil) do
    {k, _v} =
      metric.ranges()
      |> Enum.into([])
      |> hd()

    k
  end

  def range_for(_metric, val) do
    case Integer.parse(val) do
      {value, _} -> value
      :error -> val
    end
  end
end
