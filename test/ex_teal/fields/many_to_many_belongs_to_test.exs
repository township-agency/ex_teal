defmodule ExTeal.Fields.ManyToManyBelongsToTest do
  use TestExTeal.ConnCase

  alias ExTeal.Fields.ManyToManyBelongsTo

  describe "apply_options_for/4" do
    test "adds belongs to info for pivot relationships", %{conn: conn} do
      user = insert(:user)
      [_t1, t2] = insert_pair(:tag)
      t = insert(:preferred_tag, tag: t2, user: user)

      field =
        ManyToManyBelongsTo.make(
          :preferred_tags,
          TestExTeal.TagResource,
          TestExTeal.UserResource
        )
        |> ManyToManyBelongsTo.apply_options_for(t, conn, :index)

      assert field.options.belongs_to_id == t2.id
    end

    test "adds belongs_to info for non-pivot relationships", %{conn: conn} do
      [_t1, t2] = insert_pair(:tag)
      insert(:post, tags: [t2])

      field =
        ManyToManyBelongsTo.make(
          :tags,
          TestExTeal.TagResource,
          TestExTeal.PostResource
        )
        |> ManyToManyBelongsTo.apply_options_for(t2, conn, :index)

      assert field.options.belongs_to_id == t2.id
    end
  end
end
