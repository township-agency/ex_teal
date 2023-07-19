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

  defmodule EmbeddedPostResource do
    use ExTeal.Resource
    alias ExTeal.Embedded
    alias ExTeal.Fields.Text

    def fields,
      do: [
        Text.make(:name),
        Embedded.new(:location, [
          Text.make(:street_line_1),
          Text.make(:city)
        ]),
        Text.make(:description)
        |> can_see?(fn %{assigns: assigns} -> Map.get(assigns, :foo) == :bar end)
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

    test "returns all fields for an embedded resource" do
      fields = Fields.all_fields(EmbeddedPostResource)

      assert Enum.map(fields, & &1.field) == [
               :name,
               :id,
               :street_line_1,
               :city,
               :description
             ]

      assert Enum.map(fields, & &1.attribute) == [
               "name",
               :"location.id",
               :"location.street_line_1",
               :"location.city",
               "description"
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

  describe "fields_for_many_to_many/2" do
    @tag manifest: TestExTeal.DefaultManifest
    test "returns a belongs_to field for an index" do
      [t1, _t2] = insert_pair(:tag)
      p = insert(:post, tags: [t1])

      conn =
        prep_conn(:get, "/tags", %{
          "via_resource" => "posts",
          "via_resource_id" => "#{p.id}",
          "via_relationship" => "tags",
          "relationship_type" => "ManyToMany"
        })

      [field] = Fields.fields_for_many_to_many(PostResource, conn)
      assert field.type == ManyToManyBelongsTo
      assert field.relationship == TagResource
      assert field.private_options.queried_resource == PostResource
    end

    @tag manifest: TestExTeal.DefaultManifest
    test "returns pivot fields for an index" do
      u = insert(:user)

      conn =
        prep_conn(:get, "/tags", %{
          "via_resource" => "users",
          "via_resource_id" => "#{u.id}",
          "via_relationship" => "preferred_tags",
          "relationship_type" => "ManyToMany"
        })

      [tag_name, tag_type, order_field, note_field] =
        Fields.fields_for_many_to_many(UserResource, conn)

      assert tag_name.type == ExTeal.Fields.Text
      assert tag_type.type == ExTeal.Fields.Select
      assert order_field.type == ExTeal.Fields.Number
      assert note_field.type == ExTeal.Fields.Text
    end
  end

  describe "fields_for_has_many" do
    @tag manifest: TestExTeal.DefaultManifest
    test "by default returns the fields for the queried relationship" do
      conn =
        prep_conn(:get, "/posts", %{
          "via_resource" => "users",
          "via_resource_id" => "-1",
          "via_relationship" => "posts",
          "relationship_type" => "hasMany"
        })

      fields = Fields.fields_for_has_many(PostResource, conn)

      assert Enum.map(fields, & &1.field) ==
               ~w(id name published author contributor published_at deleted_at user features)a
    end

    @tag manifest: TestExTeal.PostCountManifest
    test "can be overriden based on the has many index" do
      conn =
        prep_conn(:get, "/posts", %{
          "via_resource" => "users",
          "via_resource_id" => "-1",
          "via_relationship" => "posts",
          "relationship_type" => "hasMany"
        })

      fields = Fields.fields_for_has_many(PostResource, conn)

      assert Enum.map(fields, & &1.field) == ~w(id name)a
    end
  end

  test "apply_values_for/5 hides fields based on can_see?/1" do
    p = insert(:post)

    conn = prep_conn(:get, "/post-embeds/#{p.id}")
    fields = Fields.fields_for(:index, EmbeddedPostResource)
    normal_fields = Fields.apply_values(fields, p, EmbeddedPostResource, conn, :index, nil)

    assert Enum.count(normal_fields) == 3

    conn = Plug.Conn.assign(conn, :foo, :bar)

    fields = Fields.apply_values(fields, p, EmbeddedPostResource, conn, :index, nil)
    assert Enum.count(fields) == 4
  end

  def prep_conn(method, path, params \\ %{}) do
    params = Map.merge(params, %{"_format" => "json"})

    method
    |> build_conn(path, params)
    |> fetch_query_params
  end
end
