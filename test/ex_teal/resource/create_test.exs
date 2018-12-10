defmodule ExTeal.Resource.CreateTest do
  use TestExTeal.ConnCase

  alias ExTeal.Resource.Create

  defmodule ProtectedResource do
    use ExTeal.Resource
    def repo, do: TestExTeal.Repo
    def handle_create(conn, _attrs), do: send_resp(conn, 401, "")
  end

  defmodule CustomResource do
    use ExTeal.Resource
    def repo, do: TestExTeal.Repo

    def handle_create(_c, %{"name" => "valid"}),
      do: {:ok, %TestExTeal.Post{name: "valid"}}

    def handle_create(_c, %{"name" => "invalid"}),
      do: {:error, [name: "is invalid"]}
  end

  defmodule CustomResponseResource do
    use ExTeal.Resource
    def repo, do: TestExTeal.Repo
    def model, do: TestExTeal.Post

    def handle_invalid_create(conn, _errors) do
      Serializer.as_json(conn, Jason.encode!(%{errors: "custom"}), 401)
    end

    def render_create(conn, _model) do
      Serializer.as_json(conn, Jason.encode!(%{model: "ok"}), 200)
    end
  end

  defmodule MultiCustomResource do
    use ExTeal.Resource
    alias Ecto.Multi
    alias TestExTeal.{Post, Repo}

    def repo, do: Repo

    def handle_create(_, params) do
      changeset = Post.changeset(%Post{}, params)

      Multi.new()
      |> Multi.insert(:post, changeset)
    end

    def render_create(conn, %{post: post}) do
      Serializer.render_create(post, __MODULE__, conn)
    end
  end

  test "default implementation renders 201 if valid" do
    conn = prep_conn(:post, "/posts", ja_attrs(%{"name" => "valid"}))
    response = Create.call(TestExTeal.PostResource, conn)
    assert response.status == 201
  end

  test "default implementation renders 422 if invalid" do
    conn = prep_conn(:post, "/posts", ja_attrs(%{"name" => ""}))
    response = Create.call(TestExTeal.PostResource, conn)
    assert response.status == 422
  end

  test "custom implementation accepts cons" do
    conn = prep_conn(:post, "/posts", ja_attrs(%{"name" => "valid"}))
    response = Create.call(ProtectedResource, conn)
    assert response.status == 401
  end

  test "custom implementation handles {:ok, model}" do
    conn = prep_conn(:post, "/posts", ja_attrs(%{"name" => "valid"}))
    response = Create.call(CustomResource, conn)
    assert response.status == 201
  end

  test "custom implementation handles {:error, errors}" do
    conn = prep_conn(:post, "/posts", ja_attrs(%{"name" => "invalid"}))
    response = Create.call(CustomResource, conn)
    assert response.status == 422
  end

  test "custom multi implementation handles valid data" do
    conn = prep_conn(:post, "/posts", ja_attrs(%{"name" => "valid"}))
    response = Create.call(MultiCustomResource, conn)
    assert response.status == 201
  end

  test "custom multi implementation handles invalid data" do
    conn = prep_conn(:post, "/posts", ja_attrs(%{"name" => ""}))
    response = Create.call(MultiCustomResource, conn)
    assert response.status == 422
  end

  test "custom implementation renders 200 if valid" do
    conn = prep_conn(:post, "/posts", ja_attrs(%{"name" => "valid"}))
    response = Create.call(CustomResponseResource, conn)
    assert response.status == 200
  end

  test "custom implementation renders 401 if invalid" do
    conn = prep_conn(:post, "/posts", ja_attrs(%{"name" => ""}))
    response = Create.call(CustomResponseResource, conn)
    assert response.status == 401
  end

  def prep_conn(method, path, params \\ %{}) do
    params = Map.merge(params, %{"_format" => "json"})

    method
    |> build_conn(path, params)
    |> fetch_query_params
  end

  defp ja_attrs(attrs), do: %{"data" => attrs}
end
