defmodule ExTeal.FieldFilterTest do
  use TestExTeal.ConnCase

  alias ExTeal.FieldFilter
  alias TestExTeal.PostResource

  test "for_resource/2 returns a list of potential field filters" do
    conn = prep_conn(:get, "/posts/field-filters/")
    response = FieldFilter.for_resource(PostResource, conn)
    assert 200 == response.status

    json = Jason.decode!(response.resp_body, keys: :atoms!)

    assert json[:filters] == [
             %{as: "number", field: "id"},
             %{as: "text", field: "name"},
             %{as: "text", field: "body"}
           ]
  end

  def prep_conn(method, path, params \\ %{}) do
    params = Map.merge(params, %{"_format" => "json"})

    method
    |> build_conn(path, params)
    |> fetch_query_params
  end
end
