defmodule ExTeal.Resource.IndexTest do
  use TestExTeal.ConnCase

  alias ExTeal.Resource.Index
  alias TestExTeal.{PostResource, Repo, UserResource}

  test "default implementation returns all records" do
    insert_pair(:post)
    conn = prep_conn(:get, "/posts/")
    response = Index.call(PostResource, conn)
    assert 200 == response.status

    json = Jason.decode!(response.resp_body, keys: :atoms!)
    assert [_, _] = json[:data]
  end

  test "is able to filter records based on field filters" do
    insert(:post, name: "Foo")
    insert(:post)
    filters = [%{"field" => "name", "operator" => "=", "operand" => "Foo"}]
    encoded_filters = filters |> Jason.encode!() |> :base64.encode()
    conn = prep_conn(:get, "/posts/", %{"field_filters" => encoded_filters})
    response = Index.call(PostResource, conn)
    assert 200 == response.status

    json = Jason.decode!(response.resp_body, keys: :atoms!)
    assert [_] = json[:data]
  end

  test "can search with very basic ilikes across string fields" do
    user = insert(:user, name: "Scott Taylor")
    insert(:user, name: "Other")
    conn = prep_conn(:get, "users", %{"search" => "Scott"})
    response = Index.call(UserResource, conn)
    assert 200 == response.status
    json = Jason.decode!(response.resp_body, keys: :atoms!)
    assert [u] = json[:data]
    assert u.id == user.id
  end

  test "can search by primary id" do
    [u1, _u2] = insert_pair(:user)

    conn = prep_conn(:get, "users", %{"search" => "#{u1.id}"})
    response = Index.call(UserResource, conn)
    assert 200 == response.status
    json = Jason.decode!(response.resp_body, keys: :atoms!)
    assert [u] = json[:data]
    assert u.id == u1.id
  end

  @tag manifest: TestExTeal.DefaultManifest
  test "can use a many to many relationship to return fields correctly" do
    [t1, _t2] = insert_pair(:tag)
    p = insert(:post, tags: [t1])

    conn =
      prep_conn(:get, "tags", %{
        "via_resource" => "posts",
        "via_resource_id" => "#{p.id}",
        "via_relationship" => "tags",
        "relationship_type" => "ManyToMany"
      })

    response = Index.call(TestExTeal.TagResource, conn)
    assert 200 == response.status
    json = Jason.decode!(response.resp_body, keys: :atoms!)
    [t] = json[:data]
    assert t.id == t1.id

    [field] = t.fields
    assert field.attribute == "tags"
    assert field.component == "belongs-to"
    assert field.value == t1.name

    assert field.options == %{
             belongs_to_id: t1.id,
             belongs_to_key: "id",
             belongs_to_relationship: "tags"
           }
  end

  @tag manifest: TestExTeal.DefaultManifest
  test "can use a many to many relationship to sort pivot fields correctly" do
    [t1, t2] = insert_pair(:tag)
    u = insert(:user)

    insert(:preferred_tag, user: u, tag: t2, order: 5, notes: "bar")
    insert(:preferred_tag, user: u, tag: t1, order: 2, notes: "foo")

    conn =
      prep_conn(:get, "tags", %{
        "via_resource" => "users",
        "via_resource_id" => "#{u.id}",
        "via_relationship" => "preferred_tags",
        "relationship_type" => "ManyToMany",
        "order_by" => "order",
        "order_by_direction" => "asc"
      })

    response = Index.call(TestExTeal.TagResource, conn)
    assert 200 == response.status
    json = Jason.decode!(response.resp_body, keys: :atoms!)
    [result_1, result_2] = json[:data]

    assert result_1.id == t1.id
    assert result_2.id == t2.id
  end

  @tag manifest: TestExTeal.DefaultManifest
  test "can sort by pivot fields" do
    [t1, _t2] = insert_pair(:tag)
    u = insert(:user)

    insert(:preferred_tag, user: u, tag: t1, order: 2, notes: "foo")

    conn =
      prep_conn(:get, "tags", %{
        "via_resource" => "users",
        "via_resource_id" => "#{u.id}",
        "via_relationship" => "preferred_tags",
        "relationship_type" => "ManyToMany"
      })

    response = Index.call(TestExTeal.TagResource, conn)
    assert 200 == response.status
    json = Jason.decode!(response.resp_body, keys: :atoms!)
    [t] = json[:data]
    assert t.id == t1.id
  end

  @tag manifest: TestExTeal.DefaultManifest
  test "with_pivot_fields/3 can build a query for the pivot when no schema is used" do
    [t1, _t2] = insert_pair(:tag)
    p = insert(:post, tags: [t1])

    params = %{
      "via_resource" => "posts",
      "via_resource_id" => "#{p.id}",
      "via_relationship" => "tags",
      "relationship_type" => "ManyToMany"
    }

    query = Index.with_pivot_fields(TestExTeal.Tag, params, TestExTeal.TagResource)
    [r1] = query |> Repo.all() |> Repo.preload(:posts)
    assert r1.id == t1.id
    %{posts: [post]} = r1
    assert post.id == p.id
  end

  def prep_conn(method, path, params \\ %{}) do
    params = Map.merge(params, %{"_format" => "json"})

    method
    |> build_conn(path, params)
    |> fetch_query_params
  end
end
