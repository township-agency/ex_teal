defmodule ExTeal.Resource.DeleteTest do
  use TestExTeal.ConnCase
  alias ExTeal.Resource.Delete

  defmodule FailingOnDeleteResource do
    use ExTeal.Resource
    def model, do: TestExTeal.FailingOnDeletePost
  end

  defmodule CustomResource do
    use ExTeal.Resource
    def repo, do: TestExTeal.Repo
    def model, do: TestExTeal.Post

    def handle_delete(query, conn) do
      case conn.assigns[:user] do
        %{is_admin: true} -> super(query, conn)
        _ -> send_resp(conn, 401, "ah ah ah")
      end
    end
  end

  test "default implementation renders 404 if record not found" do
    conn = prep_conn(:delete, "/posts", %{"resources" => "404"})
    response = Delete.call(TestExTeal.PostResource, conn)
    assert response.status == 404
  end

  test "default implementation returns 204 if record found" do
    post = insert(:post)
    conn = prep_conn(:delete, "/posts", %{"resources" => "#{post.id}"})
    response = Delete.call(TestExTeal.PostResource, conn)
    assert response.status == 204
  end

  test "custom implementation returns 401 if not admin" do
    post = insert(:post)
    conn = prep_conn(:delete, "/posts", %{"resources" => "#{post.id}"})
    response = Delete.call(CustomResource, conn)
    assert response.status == 401
  end

  test "custom implementation return 404 if no model" do
    conn =
      prep_conn(:delete, "/posts", %{"resources" => "404"})
      |> assign(:user, %{is_admin: true})

    response = Delete.call(CustomResource, conn)
    assert response.status == 404
  end

  test "custom implementation returns 204 if record found" do
    post = insert(:post)

    conn =
      prep_conn(:delete, "/posts", %{"resources" => "#{post.id}"})
      |> assign(:user, %{is_admin: true})

    response = Delete.call(CustomResource, conn)
    assert response.status == 204
  end

  def prep_conn(method, path, params \\ %{}) do
    params = Map.merge(params, %{"_format" => "json"})

    method
    |> build_conn(path, params)
    |> fetch_query_params
  end
end
