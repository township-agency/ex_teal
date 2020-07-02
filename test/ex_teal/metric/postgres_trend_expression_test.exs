defmodule ExTeal.Metric.PostgresTrendExpressionTest do
  use TestExTeal.ConnCase
  use Timex
  import Ecto.Query

  alias ExTeal.Metric.PostgresTrendExpression
  alias TestExTeal.Post

  defmodule NewPostTrend do
    use ExTeal.Metric.Trend

    @impl true
    def calculate(request) do
      count(request, TestExTeal.Post)
    end
  end

  describe "generate/4" do
    test "returns a query that can be used to aggregate by years" do
      two_years_ago = Timex.now() |> Timex.subtract(Duration.from_days(365 * 2))

      insert_pair(:post, inserted_at: two_years_ago)
      insert(:post)

      results =
        Post
        |> select([p], %{aggregate: fragment("count(?) as aggregate", p.id)})
        |> PostgresTrendExpression.generate(NewPostTrend, "America/Chicago", "year")
        |> Repo.all()

      assert results == [
               %{
                 date_result: two_years_ago |> Timex.format!("{YYYY}"),
                 aggregate: 2
               },
               %{
                 date_result: Timex.now() |> Timex.format!("{YYYY}"),
                 aggregate: 1
               }
             ]
    end
  end
end
