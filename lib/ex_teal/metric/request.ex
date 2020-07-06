defmodule ExTeal.Metric.Request do
  @moduledoc """
  Data Structure for building a Query for a Metric

  Used by the Metric modules to build a data result
  that is turned into a Metric Result
  """

  defstruct [:range, :uri, :resource_id, :resource, :conn, :timezone]

  @type t :: %__MODULE__{}

  alias __MODULE__

  @spec from_conn(Plug.Conn.t(), module(), module() | nil) :: Request.t()
  def from_conn(conn, metric, resource \\ nil) do
    struct(__MODULE__, %{
      uri: Map.get(conn.params, "uri"),
      range: range_for(metric, Map.get(conn.params, "range")),
      resource: resource,
      resource_id: Map.get(conn.params, "resource_id"),
      conn: conn,
      timezone: resolve_timezone(conn)
    })
  end

  @spec resolve_timezone(Plug.Conn.t()) :: String.t()
  def resolve_timezone(%Plug.Conn{params: params}) do
    application_override = Application.get_env(:ex_teal, :user_timezone_override)

    cond do
      not is_nil(application_override) ->
        application_override

      not is_nil(Map.get(params, "timezone")) ->
        Map.get(params, "timezone")

      true ->
        "Etc/UTC"
    end
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
