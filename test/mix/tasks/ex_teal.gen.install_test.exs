Code.require_file("../../mix_helper.exs", __DIR__)

defmodule Mix.Tasks.ExTeal.Gen.InstallTest do
  use ExUnit.Case

  import MixHelper
  alias Mix.Tasks.ExTeal.Gen

  setup do
    Mix.Task.clear()
    :ok
  end

  test "generates manifest file", config do
    in_tmp_project(config.test, fn ->
      Gen.Install.run("")

      assert_file("lib/ex_teal_web/ex_teal/manifest.ex", fn file ->
        assert file =~ "defmodule ExTealWeb.ExTeal.Manifest"
        assert file =~ "def application_name, do:"
      end)
    end)
  end
end
