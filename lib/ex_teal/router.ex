defmodule ExTeal.Router do
  @moduledoc """
  Provides LiveView routing for ExTeal
  """

  @doc """
  Defines a ExTeal route.

  It expects the `path` will be mounted at and a
  set of options.  You can then link to the route directly:

      <a href={~p"/teal"}>Dashboard</a>

  ## Options

   * `:on_mount` - Declares a custom list of `Phoenix.LiveView.on_mount/1`
      callbacks to add to the dashboard's `Phoenix.LiveView.Router.live_session/3`.
      A single value may also be declared.

  ## Examples

      defmodule MyAppWeb.Router do
        use Phoenix.Router
        import ExTeal.Router

        scope "/", MyWebApp do
          pipe_through [:browser]

          teal_dashboard "/teal",
            on_mount: [{MyAppWeb.UserAuth, :ensure_authenticated}]
        end
      end
  """
  defmacro teal_dashboard(path, opts \\ []) do
    opts =
      if Macro.quoted_literal?(opts) do
        Macro.prewalk(opts, &expand_alias(&1, __CALLER__))
      else
        opts
      end

      scope =
        quote bind_quoted: binding() do
          scope path, alias: false, as: false do
            {session_name, session_opts, route_opts} =
             ExTeal.Router.__options__(opts)

            import Phoenix.Router, only: [get: 4]
            import Phoenix.LiveView.Router, only: [live: 4, live_session: 3]

            live_session session_name, session_opts do
              live "/", ExTeal.PageLive, :home, route_opts
              live "/r/:resource_uri", ExTeal.IndexPage, :index, route_opts
            end
          end
        end

    quote do
      unquote(scope)

      unless Module.get_attribute(__MODULE__, :live_dashboard_prefix) do
        @live_dashboard_prefix Phoenix.Router.scoped_path(__MODULE__, path)
                                |> String.replace_suffix("/", "")
        def __live_dashboard_prefix__, do: @live_dashboard_prefix
      end
    end
  end

  defp expand_alias({:__aliases__, _, _} = alias, env),
    do: Macro.expand(alias, %{env | function: {:ex_teal, 2}})

  defp expand_alias(other, _env), do: other

  @doc false
  def __options__(options) do
    live_socket_path = Keyword.get(options, :live_socket_path, "/live")

    {
      options[:live_session_name] || :ex_teal,
      [
        # session: {__MODULE__, :__session__, []},
        root_layout: {ExTeal.LayoutView, :dash},
        on_mount: options[:on_mount] || nil
      ],
      [
        private: %{live_socket_path: live_socket_path},
        as: :ex_teal
      ]
    }
  end

  # use Plug.Router

  # alias ExTeal.Api.{
  #   CardResponder,
  #   ManyToMany,
  #   MetricResponder,
  #   ResourceResponder
  # }

  # alias ExTeal.{GlobalSearch, View}
  # alias ExTeal.Resource.Serializer
  # alias Plug.Conn

  # if Mix.env() == :dev do
  #   use Plug.Debugger, otp_app: :ex_teal
  # end

  # plug(Plug.Static,
  #   at: "/",
  #   gzip: true,
  #   brotli: true,
  #   from: {:ex_teal, "priv/static/teal"}
  # )

  # plug(Plug.Logger, log: :debug)

  # plug(Plug.Parsers, parsers: [:urlencoded])
  # plug(Plug.MethodOverride)

  # plug(:match)
  # plug(:dispatch)

  # @doc false
  # def call(conn, opts) do
  #   conn =
  #     conn
  #     |> extract_namespace(opts)
  #     |> skip_csrf_for_assets(conn.path_info)

  #   super(conn, opts)
  # end

  # @endpoints_to_protect ~w(api plugins search)

  # defp skip_csrf_for_assets(conn, [first | _]) when first in @endpoints_to_protect, do: conn

  # defp skip_csrf_for_assets(conn, _) do
  #   Conn.put_private(conn, :plug_skip_csrf_protection, true)
  # end

  # get "/api/configuration" do
  #   config = ExTeal.json_configuration(conn) |> Jason.encode!()
  #   Serializer.as_json(conn, config, 200)
  # end

  # get "/search" do
  #   resources = Enum.filter(ExTeal.searchable_resources(), & &1.policy().view_any?(conn))

  #   conn
  #   |> GlobalSearch.new(resources)
  #   |> GlobalSearch.run()
  #   |> GlobalSearch.render()
  # end

  # get("/export/:resource_name", do: ResourceResponder.export(conn, resource_name))

  # get("/api/dashboards/:name", do: CardResponder.dashboard(conn, name))

  # get("/api/:resource_name/cards", do: CardResponder.resource(conn, resource_name))

  # get("/api/metrics/:uri", do: MetricResponder.get(conn, uri))

  # get("/api/:resource_name/metrics/:uri",
  #   do: MetricResponder.resource_index(conn, resource_name, uri)
  # )

  # get("/api/:resource_name/:resource_id/metrics/:uri",
  #   do: MetricResponder.resource_detail(conn, resource_name, resource_id, uri)
  # )

  # get("/api/:resource_name", do: ResourceResponder.index(conn, resource_name))

  # get("/api/:resource_name/creation-fields",
  #   do: ResourceResponder.creation_fields(conn, resource_name)
  # )

  # get("/api/:resource_name/field/:field_name",
  #   do: ResourceResponder.field(conn, resource_name, field_name)
  # )

  # get("/api/:resource_name/field-filters",
  #   do: ResourceResponder.field_filters(conn, resource_name)
  # )

  # get("/api/:resource_name/:resource_id/attachable/:field_name",
  #   do: ManyToMany.attachable(conn, resource_name, resource_id, field_name)
  # )

  # post("/api/:resource_name/:resource_id/attach/:field_name",
  #   do: ManyToMany.attach(conn, resource_name, resource_id, field_name)
  # )

  # delete("/api/:resource_name/:resource_id/detach/:field_name",
  #   do: ManyToMany.detach(conn, resource_name, resource_id, field_name)
  # )

  # get("/api/:resource_name/creation-pivot-fields/:field_name",
  #   do: ManyToMany.creation_pivot_fields(conn, resource_name, field_name)
  # )

  # get("/api/:resource_name/:resource_id/update-pivot-fields/:field_name/:related_resource_id",
  #   do:
  #     ManyToMany.update_pivot_fields(
  #       conn,
  #       resource_name,
  #       resource_id,
  #       field_name,
  #       related_resource_id
  #     )
  # )

  # put("/api/:resource_name/:resource_id/update-pivot/:field_name/:related_resource_id",
  #   do:
  #     ManyToMany.update_pivot(
  #       conn,
  #       resource_name,
  #       resource_id,
  #       field_name,
  #       related_resource_id
  #     )
  # )

  # put("/api/:resource_name/:resource_id/reorder/:field_name",
  #   do:
  #     ManyToMany.reorder(
  #       conn,
  #       resource_name,
  #       resource_id,
  #       field_name
  #     )
  # )

  # get("/api/:resource_name/actions", do: ResourceResponder.actions_for(conn, resource_name))
  # post("/api/:resource_name/actions", do: ResourceResponder.commit_action(conn, resource_name))

  # get("/api/:resource_name/:resource_id/update-fields",
  #   do: ResourceResponder.update_fields(conn, resource_name, resource_id)
  # )

  # get("/api/:resource_name/relatable/:relationship_name",
  #   do: ResourceResponder.relatable(conn, resource_name, relationship_name)
  # )

  # get("/api/:resource_name/:resource_id",
  #   do: ResourceResponder.show(conn, resource_name, resource_id)
  # )

  # post("/api/:resource_name/",
  #   do: ResourceResponder.create(conn, resource_name)
  # )

  # put("/api/:resource_name/reorder", do: ResourceResponder.reorder(conn, resource_name))

  # put("/api/:resource_name/:resource_id",
  #   do: ResourceResponder.update(conn, resource_name, resource_id)
  # )

  # delete("/api/:resource_name",
  #   do: ResourceResponder.delete(conn, resource_name)
  # )

  # forward("/plugins/:uri", to: ExTeal.Api.PluginResponder)

  # match _ do
  #   conn
  #   |> put_resp_header("content-type", "text/html; charset=utf-8")
  #   |> Conn.send_resp(200, View.render(conn))
  #   |> halt()
  # end

  # defp extract_namespace(conn, opts) do
  #   ns = opts[:namespace] || ""
  #   Conn.assign(conn, :namespace, "/" <> ns)
  # end
end
