defmodule ExTeal.Assets do
  # Plug to serve dependency-specific assets for the dashboard.
  @moduledoc false
  import Plug.Conn

  def init(asset) when asset in [:asset], do: asset

  def call(%Plug.Conn{params: %{"file_uri" => param}} = conn, _asset) do
    contents = content_of(param)
    content_type = content_type_of(param)

    conn
    |> put_resp_header("content-type", content_type)
    |> put_resp_header("cache-control", "public, max-age=31536000, immutable")
    |> put_private(:plug_skip_csrf_protection, true)
    |> send_resp(200, contents)
    |> halt()
  end

  defp content_type_of("app.css"), do: "text/css"
  defp content_type_of("app.js"), do: "text/javascript"
  defp content_type_of(_), do: raise ArgumentError

  defp content_of(file) do
    path = Application.app_dir(:ex_teal, ["priv", "static", "assets", file])
    File.read!(path)
  end
end
