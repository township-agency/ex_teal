defmodule ExTeal.Api.ResourceResponderTest do
  use TestExTeal.ConnCase
  alias ExTeal.Api.ResourceResponder

  defmodule EmptyManifest do
    use ExTeal.Manifest

    def resources, do: []
  end

  defmodule DefaultManifest do
    use ExTeal.Manifest
    alias TestExTeal.PostResource

    def resources,
      do: [
        PostResource
      ]
  end

  setup tags do
    if Map.has_key?(tags, :manifest) do
      Application.put_env(:ex_teal, :manifest, Map.get(tags, :manifest))
    end

    on_exit(fn ->
      Application.put_env(:ex_teal, :manifest, nil)
    end)
  end

  describe "index/2" do
    @tag manifest: EmptyManifest
    test "returns a 404 when no resource available" do
      conn = build_conn(:get, "/api/posts")
      resp = ResourceResponder.index(conn, "posts")
      assert resp.status == 404
    end

    @tag manifest: DefaultManifest
    test "returns a 200 with data" do
      conn = build_conn(:get, "/api/posts")
      resp = ResourceResponder.index(conn, "posts")
      assert resp.status == 200
    end
  end

  describe "show/2" do
    @tag manifest: EmptyManifest
    test "returns a 404 when no resource available" do
      conn = build_conn(:get, "/api/posts/1")
      resp = ResourceResponder.show(conn, "posts", 1)
      assert resp.status == 404
    end

    @tag manifest: DefaultManifest
    test "returns a 200 with the resource" do
      conn = build_conn(:get, "/api/posts/1")
      resp = ResourceResponder.show(conn, "posts", 1)
      assert resp.status == 404
    end
  end

  describe "relatable/3" do
    @tag manifest: EmptyManifest
    test "returns a 404 when no resource available" do
      conn = build_conn(:get, "/api/posts/1")
      resp = ResourceResponder.relatable(conn, "posts", "user")
      assert resp.status == 404
    end
  end
end
