defmodule ExTeal.Api.ResourceResponderTest do
  use TestExTeal.ConnCase
  import TestExTeal.ConnCase, only: [test_manifests: 2]

  alias ExTeal.Api.ResourceResponder
  alias TestExTeal.{Post, Repo}

  alias TestExTeal.{
    DefaultManifest,
    EmptyManifest,
    EnoughManifest,
    ForeverManifest,
    ImmutableManifest,
    InvisibleManifest
  }

  describe "index/2" do
    @tag manifest: EmptyManifest
    test "returns a 404 when no resource available" do
      conn = build_conn(:get, "/api/posts")
      resp = ResourceResponder.index(conn, "posts")
      assert resp.status == 404
    end

    @tag manifest: InvisibleManifest
    test "invisible not visible, returns 403" do
      p = insert(:post)
      conn = build_conn(:get, "/api/posts/#{p.id}")
      resp = ResourceResponder.show(conn, "posts", p.id)
      assert resp.status == 403
    end

    test_manifests [
      {DefaultManifest, "returns a 200 with data"},
      {EnoughManifest, "uncreateable still visible, returns a 200 with data"},
      {ImmutableManifest, "uneditable still visible, returns a 200 with data"},
      {ForeverManifest, "undeleteable still visible, returns a 200 with data"}
    ] do
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

    @tag manifest: InvisibleManifest
    test "invisible not visible, returns 403" do
      p = insert(:post)
      conn = build_conn(:get, "/api/posts/#{p.id}")
      resp = ResourceResponder.show(conn, "posts", p.id)
      assert resp.status == 403
    end

    test_manifests [
      {DefaultManifest, "returns a 200 with the resource"},
      {EnoughManifest, "uncreateable still visible, returns a 200 with data"},
      {ImmutableManifest, "uneditable still visible, returns a 200 with data"},
      {ForeverManifest, "undeleteable still visible, returns a 200 with data"}
    ] do
      p = insert(:post)
      conn = build_conn(:get, "/api/posts/#{p.id}")
      resp = ResourceResponder.show(conn, "posts", p.id)
      assert resp.status == 200
    end
  end

  describe "relatable/3" do
    @tag manifest: EmptyManifest
    test "returns a 404 when no resource available" do
      conn = build_conn(:get, "/api/posts/1")
      resp = ResourceResponder.relatable(conn, "posts", "user")
      assert resp.status == 404
    end

    @tag manifest: InvisibleManifest
    test "invisible not visible, returns 403" do
      p = insert(:post)
      conn = build_conn(:get, "/api/posts/#{p.id}")
      resp = ResourceResponder.relatable(conn, "posts", "user")
      assert resp.status == 403
    end

    test_manifests [
      {DefaultManifest, "returns a 200 with the resource"},
      {EnoughManifest, "uncreateable not relatable, returns a 200 with data"},
      {ImmutableManifest, "uneditable not relatable, returns a 200 with data"},
      {ForeverManifest, "undeleteable not relatable, returns a 200 with data"}
    ] do
      p = insert(:post)
      conn = build_conn(:get, "/api/posts/#{p.id}")
      resp = ResourceResponder.relatable(conn, "posts", "user")
      assert resp.status == 200
    end
  end

  describe "actions_for/2" do
    @tag manifest: EmptyManifest
    test "returns a 404 when no resource available" do
      conn = build_conn(:get, "/api/posts/actions")
      resp = ResourceResponder.actions_for(conn, "posts")
      assert resp.status == 404
    end

    @tag manifest: InvisibleManifest
    test "invisible does not show actions, returns 403" do
      conn = build_conn(:get, "/api/posts/actions")
      resp = ResourceResponder.actions_for(conn, "posts")
      assert resp.status == 403
    end

    test_manifests [
      {DefaultManifest, "returns the actions for the resource"},
      {EnoughManifest, "uncreateable shows actions, returns a 200 with data"},
      {ImmutableManifest, "uneditable shows actions, returns a 200 with data"},
      {ForeverManifest, "undeleteable shows actions, returns a 200 with data"}
    ] do
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

    @tag manifest: InvisibleManifest
    test "invisible does not show actions, returns 403" do
      p = insert(:post)

      conn =
        build_conn(:post, "/api/posts/actions", %{
          "action" => "publish-post",
          "resources" => "#{p.id}"
        })

      resp = ResourceResponder.commit_action(conn, "posts")
      assert resp.status == 403
    end

    test_manifests [
      {DefaultManifest, "returns a 200 when complete"},
      {EnoughManifest, "uncreateable allows committing actions, returns a 200 with data"},
      {ImmutableManifest, "uneditable allows committing actions, returns a 200 with data"},
      {ForeverManifest, "undeleteable allows committing actions, returns a 200 with data"}
    ] do
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

  describe "update/2" do
    @tag manifest: ImmutableManifest
    test "returns a 403 for a single update" do
      p = insert(:post)

      conn = build_conn(:put, "/api/posts/#{p.id}", %{})

      resp = ResourceResponder.update(conn, "posts", p.id)
      assert resp.status == 403
    end
  end

  describe "delete/2" do
    @tag manifest: ForeverManifest
    test "returns a 403 for a single delete" do
      p = insert(:post)

      conn =
        build_conn(:delete, "/api/posts", %{
          "resources" => "#{p.id}"
        })

      resp = ResourceResponder.delete(conn, "posts")
      assert resp.status == 403
    end

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
      p = insert(:post, name: "Foo", user: nil)
      p2 = insert(:post, name: "Bar", user: nil)

      filters = [
        %{"field" => "name", "operator" => "=", "operand" => "Foo"}
      ]

      encoded_filters = filters |> Jason.encode!() |> :base64.encode()

      conn =
        build_conn(:delete, "/api/posts", %{
          "resources" => "all",
          "field_filters" => encoded_filters
        })

      resp = ResourceResponder.delete(conn, "posts")
      assert resp.status == 204

      refute Repo.get(Post, p.id)
      assert Repo.get(Post, p2.id)
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

    @tag manifest: DefaultManifest
    test "returns the correct non-embedded filters" do
      conn = build_conn(:get, "/api/post-embeds/field-filters")
      resp = ResourceResponder.field_filters(conn, "post-embeds")
      {:ok, body} = Jason.decode(resp.resp_body, keys: :atoms)
      assert resp.status == 200
      assert length(body.filters) == 1
    end
  end
end
