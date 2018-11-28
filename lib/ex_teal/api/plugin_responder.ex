defmodule ExTeal.Api.PluginResponder do
  @moduledoc """
  Simple Plug that routes a request to the
  appropriate plugin
  """

  alias ExTeal.Api.ErrorSerializer

  def init(opts), do: opts

  def call(conn, _opts) do
    with {:ok, plugin} <- ExTeal.plugin_for(conn.params["uri"]) do
      router = plugin.router()
      router.call(conn, router.init())
    else
      {:error, reason} -> ErrorSerializer.handle_error(conn, reason)
    end
  end
end
