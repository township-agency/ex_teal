defmodule ExTeal.Router do
  @moduledoc """
  A `Plug.Router`.  This module is meant to be plugged into host applications.

  See the readme for more details.
  """

  use Plug.Router

  alias ExTeal.Api.{ManyToMany, ResourceResponder}
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
      |> Conn.put_private(:plug_skip_csrf_protection, true)

    super(conn, opts)
  end

  get "/api/configuration" do
    config = ExTeal.json_configuration() |> Jason.encode!()
    Serializer.as_json(conn, config, 200)
  end

  get "/search" do
    conn
    |> GlobalSearch.new(ExTeal.searchable_resources())
    |> GlobalSearch.run()
    |> GlobalSearch.render()
  end

  get("/api/:resource_name", do: ResourceResponder.index(conn, resource_name))

  get("/api/:resource_name/creation-fields",
    do: ResourceResponder.creation_fields(conn, resource_name)
  )

  get("/api/:resource_name/field/:field_name",
    do: ResourceResponder.field(conn, resource_name, field_name)
  )

  get("/api/:resource_name/:resource_id/attachable/:field_name",
    do: ManyToMany.attachable(conn, resource_name, resource_id, field_name)
  )

  post("/api/:resource_name/:resource_id/attach/:field_name",
    do: ManyToMany.attach(conn, resource_name, resource_id, field_name)
  )

  delete("/api/:resource_name/:resource_id/detach/:field_name/:field_id",
    do: ManyToMany.detach(conn, resource_name, resource_id, field_name, field_id)
  )

  get("/api/:resource_name/filters", do: ResourceResponder.filters_for(conn, resource_name))

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
