defmodule ExTeal.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias ExTeal.Router

  @opts Router.init([])

  describe "GET /" do
    test "renders the layout with the manifest loaded" do
      conn = request!(:get, "/")
      assert 200 == conn.status
    end
  end

  # describe "Not Found" do
  #   test "renders a 404 with an empty response" do
  #     conn = request!(:get, "/does-not-exist")
  #     assert 404 == conn.status
  #   end
  # end

  # For GET and DELETE
  #
  defp request!(method, path) do
    method
    |> conn(path)
    |> Router.call(@opts)
  end
end
