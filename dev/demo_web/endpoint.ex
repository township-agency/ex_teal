defmodule DemoWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :ex_teal

  @session_options [
    store: :cookie,
    key: "_demo_key",
    signing_salt: "F8eNHEqrULKLsgYG",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket

  plug Phoenix.LiveReloader
  plug Phoenix.CodeReloader

  plug Plug.Session,
    store: :cookie,
    key: "_ex_teal_key",
    signing_salt: "ODO4gr/m",
    same_site: "Lax"

  plug Plug.Static,
    at: "/",
    from: "dev/static",
    gzip: false,
    only: ~w(assets fonts images favicon.ico robots.txt)

  plug DemoWeb.Router
end
