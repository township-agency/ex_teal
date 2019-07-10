defmodule ExTeal.Api.ManyToManyTest do
  use TestExTeal.ConnCase
  alias ExTeal.Api.ManyToMany
  alias TestExTeal.{DefaultManifest, EmptyManifest, Post, PreferredTag, Repo}

  describe "attachable/4" do
    @tag manifest: EmptyManifest
    test "returns a 404 for an invalid resource" do
      conn = build_conn(:get, "/api/posts/1/attachable/foo")
      resp = ManyToMany.attachable(conn, "posts", "1", "foo")
      assert resp.status == 404
    end

    @tag manifest: DefaultManifest
    test "returns a 404 for a missing field" do
      conn = build_conn(:get, "/api/posts/1/attachable/foo")
      resp = ManyToMany.attachable(conn, "posts", "1", "foo")
      assert resp.status == 404
    end

    @tag manifest: DefaultManifest
    test "returns a 404 for an invalid field" do
      conn = build_conn(:get, "/api/posts/1/attachable/title")
      resp = ManyToMany.attachable(conn, "posts", "1", "title")
      assert resp.status == 404
    end

    @tag manifest: TestExTeal.DefaultManifest
    test "returns a list of tags" do
      p = insert(:post)
      [t1, t2] = insert_pair(:tag)

      conn = build_conn(:get, "/api/posts/#{p.id}/attachable/tags")
      resp = ManyToMany.attachable(conn, "posts", "#{p.id}", "tags")
      assert resp.status == 200
      {:ok, body} = Jason.decode(resp.resp_body, keys: :atoms)
      assert Enum.map(body.data, & &1.value) == [t1.id, t2.id]
    end
  end

  describe "attach/4" do
    @tag manifest: EmptyManifest
    test "returns a 404 when no resource available" do
      conn = build_conn(:post, "/api/posts/1/attach/tags", %{})
      resp = ManyToMany.attach(conn, "posts", "1", "tags")
      assert resp.status == 404
    end

    @tag manifest: DefaultManifest
    test "returns a 404 for a missing field" do
      conn = build_conn(:post, "/api/posts/1/attach/foo", %{})
      resp = ManyToMany.attach(conn, "posts", "1", "foo")
      assert resp.status == 404
    end

    @tag manifest: DefaultManifest
    test "returns a 404 for an invalid field" do
      conn = build_conn(:post, "/api/posts/1/attach/title")
      resp = ManyToMany.attach(conn, "posts", "1", "title")
      assert resp.status == 404
    end

    @tag manifest: TestExTeal.DefaultManifest
    test "attachs a tag" do
      [t1, t2] = insert_pair(:tag)
      p = insert(:post, tags: [t1])

      conn =
        build_conn(:post, "/api/posts/#{p.id}/attach/tags", %{
          "tags" => "#{t2.id}",
          "viaRelationship" => "tags"
        })

      resp = ManyToMany.attach(conn, "posts", "#{p.id}", "tags")
      assert resp.status == 201
      post = Post |> Repo.get(p.id) |> Repo.preload(:tags)
      assert post.tags == [t1, t2]
    end

    @tag manifest: TestExTeal.DefaultManifest
    test "attaches with pivot data" do
      tag = insert(:tag)
      user = insert(:user)

      conn =
        build_conn(:post, "/api/users/#{user.id}/attach/preferred_tags", %{
          "preferred_tags" => "#{tag.id}",
          "order" => "2",
          "notes" => "foo",
          "viaRelationship" => "preferred_tags"
        })

      resp = ManyToMany.attach(conn, "users", "#{user.id}", "preferred_tags")
      assert resp.status == 201

      query =
        from(
          p in PreferredTag,
          where: p.tag_id == ^tag.id,
          where: p.user_id == ^user.id
        )

      [preferred] = Repo.all(query)
      assert preferred.order == 2
      assert preferred.notes == "foo"
    end

    @tag manifest: TestExTeal.DefaultManifest
    test "returns validation errors for bad params" do
      tag = insert(:tag)
      user = insert(:user)

      conn =
        build_conn(:post, "/api/users/#{user.id}/attach/preferred_tags", %{
          "preferred_tags" => "#{tag.id}",
          "notes" => "foo",
          "viaRelationship" => "preferred_tags"
        })

      resp = ManyToMany.attach(conn, "users", "#{user.id}", "preferred_tags")
      assert resp.status == 422
    end
  end

  describe "detach/4" do
    @tag manifest: EmptyManifest
    test "returns a 404 when no resource available" do
      conn = build_conn(:delete, "/api/posts/1/detach/tags", %{})
      resp = ManyToMany.detach(conn, "posts", "1", "tags")
      assert resp.status == 404
    end

    @tag manifest: DefaultManifest
    test "returns a 404 for a missing field" do
      conn = build_conn(:delete, "/api/posts/1/detach/foo", %{})
      resp = ManyToMany.detach(conn, "posts", "1", "foo")
      assert resp.status == 404
    end

    @tag manifest: DefaultManifest
    test "returns a 404 for an invalid field" do
      conn = build_conn(:delete, "/api/posts/1/detach/title", %{})
      resp = ManyToMany.detach(conn, "posts", "1", "title")
      assert resp.status == 404
    end

    @tag manifest: DefaultManifest
    test "returns a 404 for an unrelated field" do
      [t1, t2] = insert_pair(:tag)
      p = insert(:post, tags: [t1])

      conn =
        build_conn(:delete, "/api/posts/#{p.id}/detach/tags", %{
          "resources" => "#{t2.id}"
        })

      resp = ManyToMany.detach(conn, "posts", "#{p.id}", "tags")
      assert resp.status == 404
    end

    @tag manifest: DefaultManifest
    test "returns a 204 after detaching the field" do
      t = insert(:tag)
      p = insert(:post, tags: [t])

      conn =
        build_conn(:delete, "/api/posts/#{p.id}/detach/tags", %{
          "resources" => "#{t.id}"
        })

      resp = ManyToMany.detach(conn, "posts", "#{p.id}", "tags")

      assert resp.status == 204

      post = Post |> Repo.get(p.id) |> Repo.preload(:tags)
      assert post.tags == []
    end
  end

  describe "creation_pivot_fields/3" do
    @tag manifest: EmptyManifest
    test "returns a 404 when no resource available" do
      conn = build_conn(:get, "/api/posts/creation-pivot-fields/tags", %{})
      resp = ManyToMany.creation_pivot_fields(conn, "posts", "tags")
      assert resp.status == 404
    end

    @tag manifest: DefaultManifest
    test "returns a 404 for a missing field" do
      conn = build_conn(:get, "/api/posts/creation-pivot-fields/foo", %{})
      resp = ManyToMany.creation_pivot_fields(conn, "posts", "foo")
      assert resp.status == 404
    end

    @tag manifest: DefaultManifest
    test "returns a 404 for an invalid field" do
      conn = build_conn(:get, "/api/posts/creation-pivot-fields/title", %{})
      resp = ManyToMany.creation_pivot_fields(conn, "posts", "title")
      assert resp.status == 404
    end

    @tag manifest: DefaultManifest
    test "returns an empty list for a relationship with no pivot fields" do
      conn = build_conn(:get, "/api/posts/creation-pivot-fields/tags", %{})
      resp = ManyToMany.creation_pivot_fields(conn, "posts", "tags")
      assert resp.status == 200
      {:ok, body} = Jason.decode(resp.resp_body, keys: :atoms)
      assert body == %{fields: []}
    end

    @tag manifest: DefaultManifest
    test "returns the pivot fields" do
      conn = build_conn(:get, "/api/users/creation-pivot-fields/preferred_tags", %{})
      resp = ManyToMany.creation_pivot_fields(conn, "users", "preferred_tags")
      assert resp.status == 200
      {:ok, body} = Jason.decode(resp.resp_body, keys: :atoms)
      [f1, _f2] = body.fields
      assert f1.attribute == "order"
    end
  end
end
