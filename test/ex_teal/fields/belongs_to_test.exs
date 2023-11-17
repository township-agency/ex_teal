defmodule ExTeal.Fields.BelongsToTest do
  use TestExTeal.ConnCase
  alias ExTeal.Fields.BelongsTo
  alias TestExTeal.{Post, User}

  describe "apply_options_for/4" do
    @tag manifest: TestExTeal.DefaultManifest
    test "sets related values for an existing belongs to relationship" do
      user = insert(:user)
      post = insert(:post, user: user)
      f = BelongsTo.make(:user, User)
      conn = build_conn(:get, "/posts", %{})

      f = BelongsTo.apply_options_for(f, post, conn, nil)

      assert f.options == %{
               belongs_to_id: user.id,
               belongs_to_key: :user_id,
               belongs_to_relationship: "users",
               reverse: false
             }
    end

    @tag manifest: TestExTeal.DefaultManifest
    test "sets reverse to true when via relationship values are passed" do
      post = %Post{}
      user = insert(:user)
      f = BelongsTo.make(:user, User)

      conn =
        build_conn(:get, "/resources/posts/creation-fields", %{
          "viaResource" => "users",
          "viaResourceId" => "#{user.id}",
          "viaRelationship" => "posts"
        })

      f = BelongsTo.apply_options_for(f, post, conn, nil)

      assert f.options == %{
               belongs_to_id: nil,
               belongs_to_key: :user_id,
               belongs_to_relationship: "users",
               reverse: true
             }
    end

    @tag manifest: TestExTeal.DefaultManifest
    test "sets reverse to false when via relationship doesn't correspond" do
      post = %Post{}
      user = insert(:user)
      f = BelongsTo.make(:editor, User)

      conn =
        build_conn(:get, "/resources/posts/creation-fields", %{
          "viaResource" => "users",
          "viaResourceId" => "#{user.id}",
          "viaRelationship" => "posts"
        })

      f = BelongsTo.apply_options_for(f, post, conn, nil)

      assert f.options == %{
               belongs_to_id: nil,
               belongs_to_key: :editor_id,
               belongs_to_relationship: "users",
               reverse: false
             }
    end
  end
end
