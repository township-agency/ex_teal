defmodule ExTeal.Metric.PartitionTest do
  use TestExTeal.ConnCase
  alias ExTeal.Metric.Request
  alias TestExTeal.{Order, Post, User}

  defmodule UserCount do
    use ExTeal.Metric.Partition

    @impl true
    def calculate(_request) do
      count(User, :name)
    end
  end

  defmodule PostPublished do
    use ExTeal.Metric.Partition

    @impl true
    def calculate(_request) do
      count(Post, :published)
    end
  end

  defmodule OrderTotal do
    use ExTeal.Metric.Partition

    @impl true
    def calculate(_request) do
      sum(Order, :name, :grand_total)
    end
  end

  describe "calculate/1" do
    test "returns a result" do
      insert_pair(:user, name: "Bob")
      insert(:user, name: "Jebediah")

      results = UserCount.calculate(request())

      assert results == [
               %{label: "Bob", value: 2},
               %{label: "Jebediah", value: 1}
             ]
    end

    test "can aggregate over a boolean" do
      insert_pair(:post, published: true)
      insert(:post, published: false)

      assert PostPublished.calculate(request()) == [
               %{label: "false", value: 1},
               %{label: "true", value: 2}
             ]
    end

    test "can sum over an group by" do
      insert_pair(:order, name: "Foo", grand_total: 1_000)
      insert(:order, name: "Bar", grand_total: 1_000)

      assert OrderTotal.calculate(request()) == [
               %{label: "Bar", value: 1_000},
               %{label: "Foo", value: 2_000}
             ]
    end
  end

  describe "label_for/1" do
    test "by default converts true / false into strings" do
      assert "true" == UserCount.label_for(true)
      assert "true" == UserCount.label_for(true)
      assert "true" == UserCount.label_for(true)
    end
  end

  defp request do
    :get
    |> build_conn("/foo", %{
      "uri" => "user-count"
    })
    |> Request.from_conn()
  end
end
