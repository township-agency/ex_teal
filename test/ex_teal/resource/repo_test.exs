defmodule ExTeal.Resource.RepoTest do
  use ExUnit.Case

  defmodule ExTealDefaultResource do
    use ExTeal.Resource
  end

  defmodule ExampleCustomResource do
    use ExTeal.Resource

    def repo, do: MyApp.SecondaryRepo
  end

  test "Repo should be poplulated from settings by default" do
    assert ExTealDefaultResource.repo() == TestExTeal.Repo
  end

  test "Repo can be overriden" do
    assert ExampleCustomResource.repo() == MyApp.SecondaryRepo
  end
end
