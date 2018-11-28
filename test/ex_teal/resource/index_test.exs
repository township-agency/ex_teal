defmodule ExTeal.Resource.IndexTest do
  use TestExTeal.ConnCase

  alias ExTeal.Resource.Index
  alias TestExTeal.{PostResource, UserResource}

  test "default implementation returns all records" do
    insert_pair(:post)
    conn = prep_conn(:get, "/posts/")
    response = Index.call(PostResource, conn)
    assert 200 == response.status

    json = Jason.decode!(response.resp_body, keys: :atoms!)
    assert [_, _] = json[:data]
  end

  test "is able to filter records based on defined filters" do
    insert(:post, published: false)
    insert(:post, published: true)
    filters = [%{"key" => "published_status", "value" => 1}]
    encoded_filters = filters |> Jason.encode!() |> :base64.encode()
    conn = prep_conn(:get, "/posts/", %{"filters" => encoded_filters})
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

  def prep_conn(method, path, params \\ %{}) do
    params = Map.merge(params, %{"_format" => "json"})

    method
    |> build_conn(path, params)
    |> fetch_query_params
  end
end
