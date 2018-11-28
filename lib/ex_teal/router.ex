defmodule ExTeal.Router do
  @moduledoc """
  A `Plug.Router`.  This module is meant to be plugged into host applications.

  See the readme for more details.
  """

  use Plug.Router

  alias ExTeal.Api.ResourceResponder
  alias ExTeal.GlobalSearch
  alias ExTeal.Resource.Serializer
  alias Plug.Conn

  if Mix.env() == :dev do
    use Plug.Debugger, otp_app: :ex_teal
  end

  plug(Plug.Static,
    at: "/",
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

  get("/api/:resource_name/filters", do: ResourceResponder.filters_for(conn, resource_name))

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

  delete("/api/:resource_name/:resource_id",
    do: ResourceResponder.delete(conn, resource_name, resource_id)
  )

  forward("/plugins/:uri", to: ExTeal.Api.PluginResponder)

  match _ do
    body = build_body_with_config(conn)

    conn
    |> put_resp_header("content-type", "text/html; charset=utf-8")
    |> Conn.send_resp(200, body)
    |> halt()
  end

  defp extract_namespace(conn, opts) do
    ns = opts[:namespace] || ""
    Conn.assign(conn, :namespace, "/" <> ns)
  end

  defp build_body_with_config(conn) do
    path = Path.expand("../../priv/static/teal/index.html", __DIR__)
    {:ok, str} = File.read(path)

    base = Application.get_env(:ex_teal, :base_url)
    config = ExTeal.json_configuration()
    auth_provider = ExTeal.auth_provider()

    user = apply(auth_provider, :current_user_for, [conn])

    config_str = """
    <div id="app"></div>
    <script type="text/javascript">
      window.config = #{Jason.encode!(config)};
      window.config.baseUrl = "#{base}";
      window.config.currentUser = #{Jason.encode!(user)};
    </script>
    """

    match = ~r/<div id="?app"?><\/div>/

    end_of_page_match = ~r/<\/body>/

    str
    |> String.replace(match, config_str)
    |> String.replace(end_of_page_match, boot_order())
  end

  def boot_order,
    do: """
    <!-- Build ExTeal Instance -->
    <script>
        window.ExTeal = new CreateExTeal(config)
    </script>

    <!-- Start ExTeal -->
      <script>
          ExTeal.beamMeUp();
      </script>
    """
end
