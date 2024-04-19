defmodule DemoWeb.Router do
  use Phoenix.Router, helpers: false
  import Plug.Conn
  import Phoenix.Controller
  import Phoenix.LiveView.Router
  import ExTeal.Router

  pipeline :browser do
    plug :fetch_session
    plug :put_user_id
  end

  scope "/" do
    pipe_through :browser

    teal_dashboard("/teal",
      on_mount: [{DemoWeb.UserAuth, :ensure_authenticated}]
    )
  end

  defp put_user_id(conn, _) do
    Plug.Conn.put_session(conn, "user_id", "1")
  end
end
