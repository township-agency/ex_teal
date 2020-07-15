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

    test "returns a query that can aggregate by months" do
      dt =
        {{2020, 01, 05}, {0, 0, 0}}
        |> NaiveDateTime.from_erl!()
        |> DateTime.from_naive!("America/Chicago", Tzdata.TimeZoneDatabase)

      interval =
        [from: dt, until: [months: 5], step: [months: 1]]
        |> Interval.new()

      interval
      |> Enum.with_index(1)
      |> Enum.map(fn {date, index} ->
        insert_list(index, :post, inserted_at: date)
      end)

      results =
        Post
        |> select([p], %{aggregate: fragment("count(?) as aggregate", p.id)})
        |> PostgresTrendExpression.generate(NewPostTrend, "America/Chicago", "month")
        |> Repo.all()

      assert results == [
               %{
                 date_result: "2020-01",
                 aggregate: 1
               },
               %{
                 date_result: "2020-02",
                 aggregate: 2
               },
               %{
                 date_result: "2020-03",
                 aggregate: 3
               },
               %{
                 date_result: "2020-04",
                 aggregate: 4
               },
               %{
                 date_result: "2020-05",
                 aggregate: 5
               }
             ]
    end

    test "returns a query that can aggregate by weeks" do
      dt =
        {{2020, 01, 05}, {0, 0, 0}}
        |> NaiveDateTime.from_erl!()
        |> DateTime.from_naive!("America/Chicago")

      interval =
        [from: dt, until: [days: 10], step: [days: 2]]
        |> Interval.new()

      interval
      |> Enum.map(fn date ->
        insert(:post, inserted_at: date)
      end)

      results =
        Post
        |> select([p], %{aggregate: fragment("count(?) as aggregate", p.id)})
        |> PostgresTrendExpression.generate(NewPostTrend, "America/Chicago", "week")
        |> Repo.all()

      assert results == [
               %{
                 date_result: "2020-01",
                 aggregate: 1
               },
               %{
                 date_result: "2020-02",
                 aggregate: 3
               },
               %{
                 date_result: "2020-03",
                 aggregate: 1
               }
             ]
    end

    test "returns a query that can aggregate by hours with timezones" do
      dt =
        {{2020, 01, 05}, {5, 0, 0}}
        |> NaiveDateTime.from_erl!()
        |> DateTime.from_naive!("Etc/UTC")

      [from: dt, until: [hours: 5], step: [hours: 1]]
      |> Interval.new()
      |> Enum.map(fn date ->
        insert(:post, inserted_at: date)
      end)

      results =
        Post
        |> select([p], %{aggregate: fragment("count(?) as aggregate", p.id)})
        |> PostgresTrendExpression.generate(NewPostTrend, "America/Chicago", "hour")
        |> Repo.all()

      assert results == [
               %{
                 date_result: "2020-01-05 00:00",
                 aggregate: 1
               },
               %{
                 date_result: "2020-01-05 01:00",
                 aggregate: 1
               },
               %{
                 date_result: "2020-01-05 02:00",
                 aggregate: 1
               },
               %{
                 date_result: "2020-01-05 03:00",
                 aggregate: 1
               },
               %{
                 date_result: "2020-01-05 04:00",
                 aggregate: 1
               }
             ]
    end

    test "returns a query that can aggregate by minutes with timezones" do
      dt =
        {{2020, 01, 05}, {5, 15, 23}}
        |> NaiveDateTime.from_erl!()
        |> DateTime.from_naive!("Etc/UTC")

      [from: dt, until: [minutes: 3], step: [minutes: 1]]
      |> Interval.new()
      |> Enum.map(fn date ->
        insert(:post, inserted_at: date)
      end)

      results =
        Post
        |> select([p], %{aggregate: fragment("count(?) as aggregate", p.id)})
        |> PostgresTrendExpression.generate(NewPostTrend, "America/Chicago", "minute")
        |> Repo.all()

      assert results == [
               %{
                 date_result: "2020-01-05 00:15:00",
                 aggregate: 1
               },
               %{
                 date_result: "2020-01-05 00:16:00",
                 aggregate: 1
               },
               %{
                 date_result: "2020-01-05 00:17:00",
                 aggregate: 1
               }
             ]
    end
  end
end
