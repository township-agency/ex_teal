defmodule ExTeal.LayoutView do
  @moduledoc false
  use ExTeal.Web, :html

  import ExTeal.Components.SidebarLayout

  embed_templates("layouts/*")

  def render("dash.html", assigns), do: dash(assigns)

  def live_socket_path(conn) do
    [Enum.map(conn.script_name, &["/" | &1]) | conn.private.live_socket_path]
  end

  defp csp_nonce(conn, type) when type in [:script, :style, :img] do
    csp_nonce_assign_key = conn.private.csp_nonce_assign_key[type]
    conn.assigns[csp_nonce_assign_key]
  end

  def asset_path(conn, :css) do
    prefix = conn.private.phoenix_router.__ex_teal_prefix__()

    Phoenix.VerifiedRoutes.unverified_path(
      conn,
      conn.private.phoenix_router,
      "#{prefix}/assets/app.css"
    )
  end

  def asset_path(conn, :js) do
    prefix = conn.private.phoenix_router.__ex_teal_prefix__()

    Phoenix.VerifiedRoutes.unverified_path(
      conn,
      conn.private.phoenix_router,
      "#{prefix}/assets/app.js"
    )
  end
end
