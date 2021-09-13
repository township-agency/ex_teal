defmodule ExTeal.Fields.HasOneTest do
  use TestExTeal.ConnCase
  alias ExTeal.Fields.HasOne

  describe "apply_options_for/3" do
    @tag manifest: TestExTeal.DefaultManifest
    test "adds the related type and id to the options" do
      [_, field] = TestExTeal.SinglePostUserResource.fields()
      post = insert(:post)
      user = insert(:single_post_user, post: post)

      field = HasOne.apply_options_for(field, user, %{}, :index)
      assert field.options.has_one_relationship == :post
      assert field.options.has_one_id == post.id
    end

    @tag manifest: TestExTeal.DefaultManifest
    test "returns with an empty relationship" do
      [_, field] = TestExTeal.SinglePostUserResource.fields()
      user = insert(:single_post_user, post: nil)
      field = HasOne.apply_options_for(field, user, %{}, :index)
      assert field.options.has_one_relationship == :post
      assert field.options.has_one_id == nil
    end
  end
end
