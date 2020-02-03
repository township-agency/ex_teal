defmodule ExTeal.ActionTest do
  use TestExTeal.ConnCase
  alias ExTeal.Action
  alias TestExTeal.PostResource
  alias TestExTeal.{Post, Repo}

  describe "apply_action/2" do
    test "uses an action to apply changes" do
      [p1, p2, p3] = insert_list(3, :post, published: false)

      expected = %ExTeal.ActionResponse{
        message: "Marked 2 as Published",
        path: nil,
        type: "success",
        url: nil
      }

      c =
        build_conn(:post, "foo", %{
          "action" => "publish-post",
          "resources" => "#{p1.id},#{p3.id}"
        })

      assert {:ok, ^expected} = Action.apply_action(PostResource, c)

      assert Post |> Repo.get(p1.id) |> Map.get(:published)
      refute Post |> Repo.get(p2.id) |> Map.get(:published)
      assert Post |> Repo.get(p3.id) |> Map.get(:published)
    end

    test "no action found" do
      p = insert(:post)
      expected = {:error, :not_found}

      c =
        build_conn(:post, "foo", %{
          "action" => "foo",
          "resources" => "#{p.id}"
        })

      assert ^expected = Action.apply_action(PostResource, c)
    end

    test "no schemas found" do
      expected =
        {:ok,
         %ExTeal.ActionResponse{
           message: "Error not found",
           path: nil,
           type: "error",
           url: nil
         }}

      c =
        build_conn(:post, "foo", %{
          "action" => "publish-post",
          "resources" => "-1"
        })

      assert ^expected = Action.apply_action(PostResource, c)
    end
  end

  describe "actionable_query/2" do
    test "preloads the relationships defined with a resources `with`" do
      p = insert(:post, user: build(:user))

      c =
        build_conn(:post, "foo", %{
          "action" => "publish-post",
          "resources" => "#{p.id}"
        })

      {:ok, query} = Action.actionable_query(PostResource, c)

      [found_post] = Repo.all(query)
      assert found_post.user.id == p.user.id
    end
  end
end
