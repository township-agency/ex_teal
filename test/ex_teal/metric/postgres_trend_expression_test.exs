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
        |> PostgresTrendExpression.generate(
          NewPostTrend,
          "America/Chicago",
          "year",
          two_years_ago
        )
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
        |> PostgresTrendExpression.generate(NewPostTrend, "America/Chicago", "month", dt)
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
        |> PostgresTrendExpression.generate(NewPostTrend, "America/Chicago", "week", dt)
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
        {{2020, 01, 05}, {10, 15, 0}}
        |> NaiveDateTime.from_erl!()
        |> DateTime.from_naive!("Etc/UTC")

      interval = Interval.new(from: dt, until: [hours: 5], step: [hours: 1])

      Enum.map(interval, fn date ->
        insert(:post, inserted_at: date)
      end)

      results =
        Post
        |> select([p], %{aggregate: fragment("count(?) as aggregate", p.id)})
        |> PostgresTrendExpression.generate(NewPostTrend, "America/Chicago", "hour", dt)
        |> Repo.all()

      expected_date_results =
        Enum.map(interval, fn date ->
          tz = Timezone.get("America/Chicago", date)

          date
          |> DateTime.from_naive!("Etc/UTC")
          |> DateTime.add(-15 * 60)
          |> Timezone.convert(tz)
          |> Timex.format!("{ISOdate} {0h12}:{m}")
        end)

      assert results |> Enum.map(& &1.aggregate) |> Enum.all?(&(&1 == 1))
      assert Enum.map(results, & &1.date_result) == expected_date_results
    end

    test "returns a query that can aggregate by minutes with timezones" do
      dt =
        {{2020, 01, 05}, {10, 15, 23}}
        |> NaiveDateTime.from_erl!()
        |> DateTime.from_naive!("Etc/UTC")

      interval = Interval.new(from: dt, until: [minutes: 3], step: [minutes: 1])

      Enum.map(interval, fn date ->
        insert(:post, inserted_at: date)
      end)

      results =
        Post
        |> select([p], %{aggregate: fragment("count(?) as aggregate", p.id)})
        |> PostgresTrendExpression.generate(NewPostTrend, "America/Chicago", "minute", dt)
        |> Repo.all()

      expected_date_results =
        Enum.map(interval, fn date ->
          tz = Timezone.get("America/Chicago", date)

          date
          |> DateTime.from_naive!("Etc/UTC")
          |> Timezone.convert(tz)
          |> Timex.format!("{ISOdate} {0h12}:{m}")
        end)

      assert results |> Enum.map(& &1.aggregate) |> Enum.all?(&(&1 == 1))
      assert Enum.map(results, & &1.date_result) == expected_date_results
    end
  end
end
