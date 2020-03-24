defmodule ExTeal.Api.ResourceResponderTest do
  use TestExTeal.ConnCase
  alias ExTeal.Api.ResourceResponder
  alias TestExTeal.{Post, Repo}
  alias TestExTeal.{DefaultManifest, EmptyManifest}

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

  describe "actions_for/2" do
    @tag manifest: EmptyManifest
    test "returns a 404 when no resource available" do
      conn = build_conn(:get, "/api/posts/actions")
      resp = ResourceResponder.actions_for(conn, "posts")
      assert resp.status == 404
    end

    @tag manifest: DefaultManifest
    test "returns the actions for the resource" do
      conn = build_conn(:get, "/api/posts/actions")
      resp = ResourceResponder.actions_for(conn, "posts")
      assert resp.status == 200
      {:ok, body} = Jason.decode(resp.resp_body, keys: :atoms)
      assert Enum.map(body.actions, & &1.key) == ["publish-post"]
    end
  end

  describe "commit_action/2" do
    @tag manifest: EmptyManifest
    test "returns a 404 when no resource available" do
      conn = build_conn(:post, "/api/posts/actions")
      resp = ResourceResponder.commit_action(conn, "posts")
      assert resp.status == 404
    end

    @tag manifest: DefaultManifest
    test "returns a 200 when complete" do
      p = insert(:post)

      conn =
        build_conn(:post, "/api/posts/actions", %{
          "action" => "publish-post",
          "resources" => "#{p.id}"
        })

      resp = ResourceResponder.commit_action(conn, "posts")
      assert resp.status == 200
    end
  end

  describe "delete/2" do
    @tag manifest: EmptyManifest
    test "returns a 404 when no resource available" do
      conn = build_conn(:delete, "/api/posts")
      resp = ResourceResponder.delete(conn, "posts")
      assert resp.status == 404
    end

    @tag manifest: DefaultManifest
    test "returns a 204 for a single delete" do
      p = insert(:post)

      conn =
        build_conn(:delete, "/api/posts", %{
          "resources" => "#{p.id}"
        })

      resp = ResourceResponder.delete(conn, "posts")
      assert resp.status == 204

      refute Repo.get(Post, p.id)
    end

    @tag manifest: DefaultManifest
    test "returns a 204 for multiple ids" do
      [p1, p2, p3] = insert_list(3, :post)

      conn =
        build_conn(:delete, "/api/posts", %{
          "resources" => "#{p1.id},#{p3.id}"
        })

      resp = ResourceResponder.delete(conn, "posts")
      assert resp.status == 204

      refute Repo.get(Post, p1.id)
      refute Repo.get(Post, p3.id)
      assert Repo.get(Post, p2.id)
    end

    @tag manifest: DefaultManifest
    test "returns a 204 for all param" do
      [p1, p2, p3] = insert_list(3, :post)

      conn =
        build_conn(:delete, "/api/posts", %{
          "resources" => "all"
        })

      resp = ResourceResponder.delete(conn, "posts")
      assert resp.status == 204

      refute Repo.get(Post, p1.id)
      refute Repo.get(Post, p2.id)
      refute Repo.get(Post, p3.id)
    end

    @tag manifest: DefaultManifest
    test "returns a 204 for all with filter" do
      [p1, p2] = insert_pair(:post, published: true)
      p3 = insert(:post, published: false)

      filters = [%{"key" => "published_status", "value" => 1}]
      encoded_filters = filters |> Jason.encode!() |> :base64.encode()

      conn =
        build_conn(:delete, "/api/posts", %{
          "resources" => "all",
          "filters" => encoded_filters
        })

      resp = ResourceResponder.delete(conn, "posts")
      assert resp.status == 204

      refute Repo.get(Post, p1.id)
      refute Repo.get(Post, p2.id)
      assert Repo.get(Post, p3.id)
    end
  end

  describe "field_filters/2" do
    @tag manifest: EmptyManifest
    test "returns a 404 when no resource available" do
      conn = build_conn(:get, "/api/posts/field-filters")
      resp = ResourceResponder.field_filters(conn, "posts")
      assert resp.status == 404
    end

    @tag manifest: DefaultManifest
    test "returns a 200 with data" do
      conn = build_conn(:get, "/api/posts/field-filters")
      resp = ResourceResponder.field_filters(conn, "posts")
      assert resp.status == 200
    end
  end
end
