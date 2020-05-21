defmodule ExTeal.Router do
  @moduledoc """
  A `Plug.Router`.  This module is meant to be plugged into host applications.

  See the readme for more details.
  """

  use Plug.Router

  alias ExTeal.Api.{
    CardResponder,
    ManyToMany,
    MetricResponder,
    ResourceResponder
  }

  alias ExTeal.{GlobalSearch, View}
  alias ExTeal.Resource.Serializer
  alias Plug.Conn

  if Mix.env() == :dev do
    use Plug.Debugger, otp_app: :ex_teal
  end

  plug(Plug.Static,
    at: "/",
    gzip: true,
    brotli: true,
    from: {:ex_teal, "priv/static/teal"}
  )

  plug(Plug.Logger, log: :debug)

  plug(Plug.Parsers, parsers: [:urlencoded])
  plug(Plug.MethodOverride)

  plug(:match)
  plug(:dispatch)

  @doc false
  def call(conn, opts) do
    conn =
      conn
      |> extract_namespace(opts)
      |> skip_csrf_for_assets(conn.path_info)

    super(conn, opts)
  end

  @endpoints_to_protect ~w(api plugins search)

  defp skip_csrf_for_assets(conn, [first | _]) when first in @endpoints_to_protect, do: conn

  defp skip_csrf_for_assets(conn, _) do
    Conn.put_private(conn, :plug_skip_csrf_protection, true)
  end

  get "/api/configuration" do
    config = ExTeal.json_configuration(conn) |> Jason.encode!()
    Serializer.as_json(conn, config, 200)
  end

  get "/search" do
    conn
    |> GlobalSearch.new(ExTeal.searchable_resources())
    |> GlobalSearch.run()
    |> GlobalSearch.render()
  end

  get("/export/:resource_name", do: ResourceResponder.export(conn, resource_name))

  get("/api/dashboards/:name", do: CardResponder.dashboard(conn, name))

  get("/api/:resource_name/cards", do: CardResponder.resource(conn, resource_name))

  get("/api/metrics/:uri", do: MetricResponder.get(conn, uri))

  get("/api/:resource_name/metrics/:uri",
    do: MetricResponder.resource_index(conn, resource_name, uri)
  )

  get("/api/:resource_name/:resource_id/metrics/:uri",
    do: MetricResponder.resource_detail(conn, resource_name, resource_id, uri)
  )

  get("/api/:resource_name", do: ResourceResponder.index(conn, resource_name))

  get("/api/:resource_name/creation-fields",
    do: ResourceResponder.creation_fields(conn, resource_name)
  )

  get("/api/:resource_name/field/:field_name",
    do: ResourceResponder.field(conn, resource_name, field_name)
  )

  get("/api/:resource_name/field-filters",
    do: ResourceResponder.field_filters(conn, resource_name)
  )

  get("/api/:resource_name/:resource_id/attachable/:field_name",
    do: ManyToMany.attachable(conn, resource_name, resource_id, field_name)
  )

  post("/api/:resource_name/:resource_id/attach/:field_name",
    do: ManyToMany.attach(conn, resource_name, resource_id, field_name)
  )

  delete("/api/:resource_name/:resource_id/detach/:field_name",
    do: ManyToMany.detach(conn, resource_name, resource_id, field_name)
  )

  get("/api/:resource_name/creation-pivot-fields/:field_name",
    do: ManyToMany.creation_pivot_fields(conn, resource_name, field_name)
  )

  get("/api/:resource_name/:resource_id/update-pivot-fields/:field_name/:related_resource_id",
    do:
      ManyToMany.update_pivot_fields(
        conn,
        resource_name,
        resource_id,
        field_name,
        related_resource_id
      )
  )

  put("/api/:resource_name/:resource_id/update-pivot/:field_name/:related_resource_id",
    do:
      ManyToMany.update_pivot(
        conn,
        resource_name,
        resource_id,
        field_name,
        related_resource_id
      )
  )

  put("/api/:resource_name/:resource_id/reorder/:field_name",
    do:
      ManyToMany.reorder(
        conn,
        resource_name,
        resource_id,
        field_name
      )
  )

  get("/api/:resource_name/actions", do: ResourceResponder.actions_for(conn, resource_name))
  post("/api/:resource_name/actions", do: ResourceResponder.commit_action(conn, resource_name))

  get("/api/:resource_name/:resource_id/update-fields",
    do: ResourceResponder.update_fields(conn, resource_name, resource_id)
  )

  get("/api/:resource_name/relatable/:relationship_name",
    do: ResourceResponder.relatable(conn, resource_name, relationship_name)
  )

  get("/api/:resource_name/:resource_id",
    do: ResourceResponder.show(conn, resource_name, resource_id)
  )

  post("/api/:resource_name/",
    do: ResourceResponder.create(conn, resource_name)
  )

  put("/api/:resource_name/reorder", do: ResourceResponder.reorder(conn, resource_name))

  put("/api/:resource_name/:resource_id",
    do: ResourceResponder.update(conn, resource_name, resource_id)
  )

  delete("/api/:resource_name",
    do: ResourceResponder.delete(conn, resource_name)
  )

  forward("/plugins/:uri", to: ExTeal.Api.PluginResponder)

  match _ do
    conn
    |> put_resp_header("content-type", "text/html; charset=utf-8")
    |> Conn.send_resp(200, View.render(conn))
    |> halt()
  end

  defp extract_namespace(conn, opts) do
    ns = opts[:namespace] || ""
    Conn.assign(conn, :namespace, "/" <> ns)
  end
end
