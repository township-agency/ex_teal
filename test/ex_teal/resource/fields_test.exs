defmodule ExTeal.Resource.FieldsTest do
  use TestExTeal.ConnCase

  alias ExTeal.Fields.{ManyToManyBelongsTo, Text}
  alias ExTeal.Resource.Fields
  alias TestExTeal.{PostResource, TagResource, UserResource}

  defmodule SimplePostResource do
    use ExTeal.Resource
    alias ExTeal.Fields.Text

    def fields,
      do: [
        Text.make(:name),
        Text.make(:description)
      ]
  end

  defmodule PanelPostResource do
    use ExTeal.Resource
    alias ExTeal.Fields.Text
    alias ExTeal.Panel

    def title, do: "Posts"

    def fields,
      do: [
        Text.make(:name),
        Panel.new("Content", [
          Text.make(:description)
        ])
      ]
  end

  describe "all_fields/1" do
    test "returns all fields for a simple resource" do
      fields = Fields.all_fields(SimplePostResource)
      assert fields == SimplePostResource.fields()
    end

    test "a resource with a panel returns the nested fields" do
      fields = Fields.all_fields(PanelPostResource)

      assert fields == [
               Text.make(:name),
               :description |> Text.make() |> Map.put(:panel, :content)
             ]
    end
  end

  describe "field_for/2" do
    test "returns the field in an ok tuple" do
      [name | _] = SimplePostResource.fields()

      assert {:ok, name} == Fields.field_for(SimplePostResource, "name")
    end

    test "returns an error tuple" do
      assert {:error, :not_found} == Fields.field_for(SimplePostResource, "foo")
    end
  end

  describe "fields_for_many_to_many/3" do
    @tag manifest: TestExTeal.DefaultManifest
    test "returns a belongs_to field for an index" do
      [t1, _t2] = insert_pair(:tag)
      p = insert(:post, tags: [t1])

      conn =
        prep_conn(:get, "tags", %{
          "via_resource" => "posts",
          "via_resource_id" => "#{p.id}",
          "via_relationship" => "tags",
          "relationship_type" => "ManyToMany"
        })

      [field] = Fields.fields_for_many_to_many(:index, PostResource, conn)
      assert field.type == ManyToManyBelongsTo
      assert field.relationship == TagResource
      assert field.private_options.queried_resource == PostResource
    end

    @tag manifest: TestExTeal.DefaultManifest
    test "returns pivot fields for an index" do
      [t1, t2] = insert_pair(:tag)
      u = insert(:user)

      insert(:preferred_tag)
      insert(:preferred_tag, user: u, tag: t2, order: 2, notes: "foo")
      insert(:preferred_tag, user: u, tag: t1, order: 1, notes: "bar")

      conn =
        prep_conn(:get, "tags", %{
          "via_resource" => "users",
          "via_resource_id" => "#{u.id}",
          "via_relationship" => "preferred_tags",
          "relationship_type" => "ManyToMany"
        })

      [tag_field, order_field, note_field] =
        Fields.fields_for_many_to_many(:index, UserResource, conn)

      assert tag_field.type == ManyToManyBelongsTo
      assert tag_field.relationship == TagResource
      assert tag_field.private_options.queried_resource == UserResource
      assert order_field.type == ExTeal.Fields.Number
      assert note_field.type == ExTeal.Fields.Text
    end
  end

  def prep_conn(method, path, params \\ %{}) do
    params = Map.merge(params, %{"_format" => "json"})

    method
    |> build_conn(path, params)
    |> fetch_query_params
  end
end
