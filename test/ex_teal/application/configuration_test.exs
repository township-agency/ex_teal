defmodule ExTeal.Application.ConfigurationTest do
  use ExUnit.Case
  import Phoenix.ConnTest, only: [build_conn: 0]

  alias ExTeal.Application.Configuration

  defmodule FooResource do
    use ExTeal.Resource

    def model, do: FooSchema

    def search, do: []
  end

  defmodule FakeManifest do
    use ExTeal.Manifest
    def resources, do: [FooResource]
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

  describe "application_name/0" do
    defmodule ExTealTest.Config do
      use ExTeal.Application.Configuration
    end

    defmodule ExTealTest.CustomNameConfig do
      use ExTeal.Application.Configuration

      def application_name, do: "Foo"
    end

    alias ExTealTest.{Config, CustomNameConfig}

    test "defaults to ExTeal" do
      assert Config.application_name() == "ExTeal"
    end

    test "can be overriden" do
      assert CustomNameConfig.application_name() == "Foo"
    end
  end

  describe "nav_groups/1" do
    defmodule CustomGroups do
      use ExTeal.Manifest
    end

    test "defaults to only the default group" do
      assert CustomGroups.nav_groups(%{}) == ["Resources"]
    end

    test "Can be overriden" do
      assert FakeManifest.nav_groups(%{}) == ~w(Foo Resources Bar)
      json = Configuration.parse_json(%{})
      assert json.nav_groups == ~w(Foo Resources Bar)
    end
  end

  describe "logo_image_path/0" do
    defmodule ExTealTest.CustomLogoConfig do
      use ExTeal.Application.Configuration

      def logo_image_path, do: "/assets/static/images/brand.svg"
    end

    alias ExTealTest.{Config, CustomLogoConfig}

    test "defaults to /assets/static/images/logo.svg" do
      assert Config.logo_image_path() == "/teal/images/logo.svg"
    end

    test "can be overriden" do
      assert CustomLogoConfig.logo_image_path() == "/assets/static/images/brand.svg"
    end
  end

  describe "parse_json/1" do
    test "includes the name of the application" do
      resp = Configuration.parse_json(build_conn())
      assert resp.name == "Fake App"
    end

    test "includes the path to teal" do
      resp = Configuration.parse_json(build_conn())
      assert resp.path == "/teal"
    end

    test "a list of resources" do
      resp = Configuration.parse_json(build_conn())

      assert resp.resources == [
               %{
                 title: "Foos",
                 singular: "Foo",
                 uri: "foos",
                 group: nil,
                 hidden: false,
                 searchable: false,
                 skip_sanitize: false,
                 can_create_any: true,
                 can_delete_any: true,
                 can_update_any: true,
                 can_view_any: true
               }
             ]
    end
  end
end
