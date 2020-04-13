defmodule ExTeal.FieldFilterTest do
  use TestExTeal.ConnCase

  alias ExTeal.FieldFilter
  alias ExTeal.FieldFilter.{Number, Text}
  alias TestExTeal.{Post, PostResource}

  test "for_resource/2 returns a list of potential field filters" do
    conn = prep_conn(:get, "/posts/field-filters/")
    response = FieldFilter.for_resource(PostResource, conn)
    assert 200 == response.status

    json = Jason.decode!(response.resp_body)

    assert json["filters"] == [
             %{"as" => "number", "field" => "Id", "operators" => Number.operators()},
             %{"as" => "text", "field" => "Name", "operators" => Text.operators()},
             %{"as" => "text", "field" => "Body", "operators" => Text.operators()}
           ]
  end

  test "query/3 builds a query using the fields and filters" do
    p = insert(:post, name: "Foo", user: nil)
    insert(:post, name: "Bar", user: nil)

    filters = [
      %{"field" => "name", "operator" => "=", "operand" => "Foo"}
    ]

    [result] = FieldFilter.query(Post, filters, PostResource) |> Repo.all()
    assert result.id == p.id
  end

  def prep_conn(method, path, params \\ %{}) do
    params = Map.merge(params, %{"_format" => "json"})

    method
    |> build_conn(path, params)
    |> fetch_query_params()
  end
end
