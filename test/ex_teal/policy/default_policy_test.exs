defmodule ExTeal.Policy.DefaultPolicyTest do
  use ExUnit.Case
  import Phoenix.ConnTest, only: [build_conn: 0]

  alias ExTeal.Application.Configuration

  defmodule VisibleResource do
    use ExTeal.Resource

    def policy, do: TestExTeal.VisiblePolicy

    def model, do: FooSchema

    def search, do: []
  end

  defmodule InvisibleResource do
    use ExTeal.Resource

    def policy, do: TestExTeal.InvisiblePolicy

    def model, do: FooSchema

    def search, do: []
  end

  defmodule FakeManifest do
    use ExTeal.Manifest
    def resources, do: [VisibleResource, InvisibleResource]
    def default_policy, do: TestExTeal.InvisiblePolicy
    def application_name, do: "Fake App"
    def plugins, do: []
    def nav_groups(_), do: ~w(Foo Resources Bar)
  end

  setup do
    Application.put_env(:ex_teal, :manifest, FakeManifest)

    on_exit(fn ->
      Application.put_env(:ex_teal, :manifest, nil)
    end)
  end

  describe "parse_json/1" do
    test "will not list an unviewable resource" do
      resp = Configuration.parse_json(build_conn())

      assert resp.resources == [
               %{
                 title: "Visibles",
                 singular: "Visible",
                 uri: "visibles",
                 group: nil,
                 hidden: false,
                 searchable: false,
                 skip_sanitize: false,
                 can_create_any: true,
                 can_delete_any: true,
                 can_update_any: true,
                 can_view_any: true,
                 default_filters: nil
               }
             ]
    end
  end
end
