defmodule ExTeal.Resource.ShowTest do
  use TestExTeal.ConnCase

  alias ExTeal.Resource.Show
  alias TestExTeal.{Post, Repo}

  defmodule DefaultResource do
    use ExTeal.Resource
    alias TestExTeal.{Post, Repo}
    def model, do: Post
    def repo, do: Repo
    def records(_), do: Post
  end

  test "default implementation return 404 if not found" do
    conn = prep_conn(:get, "/posts/404", %{"id" => 404})
    response = Show.call(DefaultResource, conn, 404)
    assert response.status == 404
    {:ok, body} = Jason.decode(response.resp_body)

    assert body == %{
             "errors" => %{
               "detail" => "The resource was not found",
               "status" => 404,
               "title" => "Not Found"
             }
           }
  end

  test "default implementation return 200 if found" do
    conn = prep_conn(:get, "/posts/200", %{"id" => 200})
    Repo.insert(%Post{id: 200})
    response = Show.call(DefaultResource, conn, 200)
    assert response.status == 200
  end

  def prep_conn(method, path, params \\ %{}) do
    params = Map.merge(params, %{"_format" => "json"})

    method
    |> build_conn(path, params)
    |> fetch_query_params
  end
end
