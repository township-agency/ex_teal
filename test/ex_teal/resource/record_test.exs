defmodule ExTeal.Resource.RecordTest do
  use TestExTeal.ConnCase
  alias TestExTeal.Post
  alias TestExTeal.PostResource

  defmodule Custom do
    use ExTeal.Resource.Record
    alias TestExTeal.{Post, Repo}

    def records(_), do: Post

    def record(query, id) do
      Repo.get_by(query, name: id)
    end
  end

  test "it should return the model by default" do
    p = insert(:post, user: nil)
    result = PostResource.record(Post, p.id)
    assert result.id == p.id
  end

  test "it should be allowed to be overriden" do
    p = insert(:post, name: "Foo Bar")
    result = Custom.record(Post, "Foo Bar")
    assert result.id == p.id
  end
end
