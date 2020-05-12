Code.require_file("../../mix_helper.exs", __DIR__)

defmodule Mix.Tasks.ExTeal.Gen.ResourceTest do
  use ExUnit.Case

  import MixHelper
  alias Mix.Tasks.ExTeal.Gen

  setup do
    Mix.Task.clear()
    :ok
  end

  test "generates resource file", config do
    in_tmp_project(config.test, fn ->
      Gen.Install.run("")
      Gen.Resource.run(["Accounts.User", "name:text_area", "admin:boolean"])

      assert_file("lib/ex_teal_web/ex_teal/resources/user_resource.ex", fn file ->
        assert file =~ "defmodule ExTealWeb.ExTeal.UserResource"
        assert file =~ "alias ExTeal.Fields.{Boolean, ID, TextArea}"
        assert file =~ "TextArea.make(:name)"
        assert file =~ "Boolean.make(:admin)"
      end)

      assert_file("lib/ex_teal_web/ex_teal/manifest.ex", fn file ->
        assert file =~ "alias ExTealWeb.ExTeal.{UserResource"
        assert file =~ "def resources, do: [UserResource"
      end)
    end)
  end

  test "if manifest not found, prompts user to run install command", config do
    in_tmp_project(config.test, fn ->
      assert_raise Mix.Error,
                   ~r/Expected to find a manifest.ex file, please run 'mix ex_teal.gen.install before generating a resource./,
                   fn ->
                     Gen.Resource.run(["Accounts.User", "name:text_area", "admin:boolean"])
                   end
    end)
  end

  test "generating more resources does not overwrite aliases in manifest", config do
    in_tmp_project(config.test, fn ->
      Gen.Install.run("")
      Gen.Resource.run(["Accounts.User", "name:text_area", "admin:boolean"])
      Gen.Resource.run(["Accounts.Address", "street:text_area", "zip:text_area"])
      Gen.Resource.run(["Content.Article", "title:text_area"])

      assert_file("lib/ex_teal_web/ex_teal/manifest.ex", fn file ->
        assert file =~
                 "alias ExTealWeb.ExTeal.{UserResource,AddressResource,ArticleResource}"

        assert file =~
                 "def resources, do: [UserResource,AddressResource,ArticleResource]"
      end)
    end)
  end

  test "generates resource without context", config do
    in_tmp_project(config.test, fn ->
      Gen.Install.run("")
      Gen.Resource.run(["User", "name:text_area", "admin:boolean"])

      assert_file("lib/ex_teal_web/ex_teal/resources/user_resource.ex", fn file ->
        assert file =~ "defmodule ExTealWeb.ExTeal.UserResource"
        assert file =~ "alias ExTeal.Fields.{Boolean, ID, TextArea}"
      end)
    end)
  end

  test "generates field and aliases for belongs to assoc with context", config do
    in_tmp_project(config.test, fn ->
      Gen.Install.run("")
      Gen.Resource.run(["User", "assoc:vc_fund:belongs_to:context:profiles", "admin:boolean"])

      assert_file("lib/ex_teal_web/ex_teal/resources/user_resource.ex", fn file ->
        assert file =~ "defmodule ExTealWeb.ExTeal.UserResource"
        assert file =~ "BelongsTo.make(:vc_fund, VcFund)"
        assert file =~ "alias ExTeal.Fields.{BelongsTo"
        assert file =~ "alias ExTeal.Profiles.{VcFund"
      end)
    end)
  end

  test "generates aliases for multiple assocs", config do
    in_tmp_project(config.test, fn ->
      Gen.Install.run("")

      Gen.Resource.run([
        "User",
        "assoc:vc_fund:belongs_to:context:profiles",
        "assoc:portfolio_company:has_many:context:profiles"
      ])

      assert_file("lib/ex_teal_web/ex_teal/resources/user_resource.ex", fn file ->
        assert file =~ "defmodule ExTealWeb.ExTeal.UserResource"
        assert file =~ "BelongsTo.make(:vc_fund, VcFund)"
        assert file =~ "alias ExTeal.Fields.{BelongsTo"
        assert file =~ "alias ExTeal.Profiles.{PortfolioCompany, VcFund"
      end)
    end)
  end

  test "generates search block w/ eligible default fields", config do
    in_tmp_project(config.test, fn ->
      Gen.Install.run("")

      Gen.Resource.run([
        "Article",
        "body:text_area",
        "title:text",
        "order:number",
        "published:boolean"
      ])

      assert_file("lib/ex_teal_web/ex_teal/resources/article_resource.ex", fn file ->
        assert file =~ "def search, do: [:order, :title, :body"
      end)
    end)
  end

  describe "invalid mix arguments" do
    test "does not generate resource for bad schema arg", config do
      in_tmp_project(config.test, fn ->
        assert_raise Mix.Error,
                     ~r/Expected the resource argument, "user", to be a valid module name/,
                     fn ->
                       Gen.Install.run("")
                       Gen.Resource.run(["user", "name:text_area", "admin:boolean"])
                     end
      end)
    end

    test "does not generate resource for context arg", config do
      in_tmp_project(config.test, fn ->
        assert_raise Mix.Error,
                     ~r/Expected the resource argument, "accounts.User", to be a valid module name/,
                     fn ->
                       Gen.Install.run("")
                       Gen.Resource.run(["accounts.User", "name:text_area", "admin:boolean"])
                     end
      end)
    end

    test "error if invalid field type", config do
      in_tmp_project(config.test, fn ->
        assert_raise Mix.Error,
                     ~r/Unknown type `:bad_field` given to generator. The supported types are: ID, array, belongs_to, boolean, color, date, date_time, has_many, has_one, integer, many_to_many, many_to_many_belongs_to, multi_select, number, password, place, rich_text, select, text, text_area, toggle/,
                     fn ->
                       Gen.Install.run("")
                       Gen.Resource.run(["Accounts.User", "name:bad_field", "admin:boolean"])
                     end
      end)
    end
  end
end
