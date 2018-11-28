defmodule ExTealTest do
  use TestExTeal.ConnCase
  alias TestExTeal.{PostResource, UserResource}

  defmodule TestManifest do
    use ExTeal.Manifest
    def application_name, do: "Foo"

    def resources, do: []
  end

  setup tags do
    case Map.get(tags, :manifest) do
      nil ->
        :ok

      manifest ->
        Application.put_env(:ex_teal, :manifest, manifest)
    end

    on_exit(fn ->
      Application.put_env(:ex_teal, :manifest, nil)
    end)
  end

  describe "application_name/0" do
    test "falls back to 'ExTeal'" do
      Application.put_env(:ex_teal, :manifest, nil)
      assert ExTeal.application_name() == "ExTeal"
    end

    @tag manifest: TestManifest
    test "calls the manifest to determine the name" do
      assert ExTeal.application_name() == "Foo"
    end
  end

  describe "resource_for_relationship/2" do
    @tag manifest: TestExTeal.DefaultManifest
    test "returns the relationship resource" do
      assert {:ok, UserResource} == ExTeal.resource_for_relationship(PostResource, "user")
    end
  end

  describe "searchable_resources/0" do
    defmodule FullManifest do
      use ExTeal.Manifest

      def resources,
        do: [
          TestExTeal.PostResource,
          TestExTeal.UserResource
        ]
    end

    @tag manifest: TestManifest
    test "returns an empty list for a manifest w/o resources" do
      assert ExTeal.searchable_resources() == []
    end

    @tag manifest: FullManifest
    test "returns all resources that are sortable" do
      assert ExTeal.searchable_resources() == [TestExTeal.UserResource]
    end
  end
end
