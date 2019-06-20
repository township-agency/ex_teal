defmodule ExTeal.Resource.UpdateTest do
  use TestExTeal.ConnCase

  alias ExTeal.Resource.Update
  alias TestExTeal.{Post, Repo}

  defmodule CustomResource do
    use ExTeal.Resource
    def repo, do: TestExTeal.Repo
    def model, do: TestExTeal.Post
    def handle_update(c, nil, _attrs), do: send_resp(c, 420, "")

    def handle_update(_c, _post, %{"name" => "valid"}) do
      {:ok, %TestExTeal.Post{name: "valid"}}
    end

    def handle_update(_c, _post, _) do
      {:error, [name: "is invalid"]}
    end
  end

  defmodule CustomResponseResource do
    use ExTeal.Resource
    def repo, do: TestExTeal.Repo
    def model, do: TestExTeal.Post

    def handle_invalid_update(conn, _errors) do
      Serializer.as_json(conn, Jason.encode!(%{errors: "custom"}), 401)
    end

    def render_update(conn, _model) do
      Serializer.as_json(conn, Jason.encode!(%{model: "ok"}), 201)
    end
  end

  defmodule MultiCustomResource do
    use ExTeal.Resource

    alias Ecto.Multi
    alias TestExTeal.{Post, Repo}

    def repo, do: Repo
    def model, do: Post

    def handle_update(_c, post, params) do
      changeset = Post.changeset(post, params)

      Multi.new()
      |> Multi.update(:post, changeset)
    end

    def render_update(conn, %{post: post}) do
      Serializer.render_update(post, __MODULE__, conn)
    end
  end

  test "default implementation renders 404 if record not found" do
    conn = prep_conn(:put, "/posts/404", %{"name" => "valid"})
    response = Update.call(TestExTeal.PostResource, 404, conn)
    assert response.status == 404
  end

  @tag manifest: TestExTeal.DefaultManifest
  test "default implementation renders 200 if valid" do
    post = insert(:post)
    conn = prep_conn(:put, "/posts/#{post.id}", %{"name" => "valid"})
    response = Update.call(TestExTeal.PostResource, post.id, conn)
    assert response.status == 200
  end

  test "default implementation renders 422 if invalid" do
    post = insert(:post)
    conn = prep_conn(:put, "/posts/#{post.id}", %{"name" => ""})
    response = Update.call(TestExTeal.PostResource, post.id, conn)
    assert response.status == 422
  end

  test "custom implementation renders conn if returned" do
    conn = prep_conn(:put, "/posts/420", %{"name" => "valid"})
    response = Update.call(CustomResource, 420, conn)
    assert response.status == 420
  end

  test "custom implementation renders 200 if valid" do
    post = insert(:post)
    conn = prep_conn(:put, "/posts/#{post.id}", %{"name" => "valid"})
    response = Update.call(CustomResource, post.id, conn)
    assert response.status == 200
  end

  test "custom implementation renders 422 if invalid" do
    post = insert(:post)
    conn = prep_conn(:put, "/posts/#{post.id}", %{"name" => ""})
    response = Update.call(CustomResource, post.id, conn)
    assert response.status == 422
  end

  test "custom implementation renders 401 if invalid" do
    post = insert(:post)
    conn = prep_conn(:put, "/posts/#{post.id}", %{"name" => ""})
    response = Update.call(CustomResponseResource, post.id, conn)
    assert response.status == 401
  end

  test "custom implementation renders 201 if valid" do
    post = insert(:post)
    conn = prep_conn(:put, "/posts/#{post.id}", %{"name" => "valid"})
    response = Update.call(CustomResponseResource, post.id, conn)
    assert response.status == 201
  end

  test "custom multi implementation renders 200 if valid" do
    post = insert(:post)
    conn = prep_conn(:put, "/posts/#{post.id}", %{"name" => "valid"})
    response = Update.call(MultiCustomResource, post.id, conn)
    assert response.status == 200
  end

  test "custom multi implementation renders 422 if invalid" do
    post = insert(:post)
    conn = prep_conn(:put, "/posts/#{post.id}", %{"name" => ""})
    response = Update.call(MultiCustomResource, post.id, conn)
    assert response.status == 422
  end

  def prep_conn(method, path, params \\ %{}) do
    params = Map.merge(params, %{"_format" => "json"})

    method
    |> build_conn(path, params)
    |> fetch_query_params
  end
end
