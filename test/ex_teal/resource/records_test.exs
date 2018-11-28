defmodule ExTeal.Resource.RecordsTest do
  use TestExTeal.ConnCase

  defmodule Default do
    use ExTeal.Resource
    def model, do: TestExTeal.Post
  end

  defmodule Custom do
    use ExTeal.Resource
    def records(_, _), do: CustomModel
  end

  test "it should return a query for the model" do
    assert %Ecto.Query{} = Default.records(%{}, Default)
  end

  test "it should be allowed to be overriden" do
    assert Custom.records(%{}, Custom) == CustomModel
  end
end
