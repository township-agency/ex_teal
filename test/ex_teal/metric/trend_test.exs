defmodule ExTeal.Metric.TrendTest do
  use TestExTeal.ConnCase
  use Timex
  import Ecto.Query

  alias Decimal, as: D
  alias ExTeal.Metric.{Request, Trend}
  alias TestExTeal.{NewUserTrend, RevenueTrend}
  alias TestExTeal.{Order, User}

  describe "aggregate/5" do
    test "returns data by year" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "range" => "year",
            "start" => "2016",
            "end" => "2017"
          }),
          NewUserTrend
        )

      insert(:user, inserted_at: from_erl({{2017, 1, 5}, {0, 0, 0}}))

      result = Trend.aggregate(NewUserTrend, request, User, :count, :id)

      assert result == [
               %{date: "2016", value: D.new(0)},
               %{date: "2017", value: D.new(1)}
             ]
    end

    test "returns data by month" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "range" => "month",
            "start" => "2020-01",
            "end" => "2020-04"
          }),
          NewUserTrend
        )

      insert(:user, inserted_at: from_erl({{2020, 1, 5}, {0, 0, 0}}))
      insert_pair(:user, inserted_at: from_erl({{2020, 3, 5}, {0, 0, 0}}))

      result = Trend.aggregate(NewUserTrend, request, User, :count, :id)

      assert result == [
               %{date: "January 2020", value: D.new(1)},
               %{date: "February 2020", value: D.new(0)},
               %{date: "March 2020", value: D.new(2)},
               %{date: "April 2020", value: D.new(0)}
             ]
    end

    test "can return sum aggregations by week" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "revenue-trend",
            "range" => "week",
            "start" => "2020-07-06",
            "end" => "2020-07-13"
          }),
          RevenueTrend
        )

      insert(:order, grand_total: 100, inserted_at: from_erl({{2020, 7, 7}, {0, 0, 0}}))
      insert_pair(:order, grand_total: 23, inserted_at: from_erl({{2020, 7, 14}, {0, 0, 0}}))

      result = Trend.aggregate(RevenueTrend, request, Order, :sum, :grand_total)

      assert result == [
               %{date: "July 6 - July 12", value: D.new(100)},
               %{date: "July 13 - July 19", value: D.new(46)}
             ]
    end
  end

  def from_erl(erl, tz \\ "Etc/UTC") do
    erl
    |> NaiveDateTime.from_erl!()
    |> DateTime.from_naive!(tz)
  end

  describe "get_aggregate_datetimes/2" do
    test "for a year range with UTC" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "range" => "year",
            "start" => "2016",
            "end" => "2016"
          }),
          NewUserTrend
        )

      assert Trend.get_aggregate_datetimes(request, "Etc/UTC") ==
               {~U[2016-01-01 00:00:00Z], ~U[2016-12-31 23:59:59Z]}
    end

    test "for a start year with no end and a user timezone" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "range" => "year",
            "timezone" => "America/Chicago",
            "start" => "2015"
          }),
          NewUserTrend
        )

      assert Trend.get_aggregate_datetimes(request, "America/Chicago") ==
               {
                 Timex.to_datetime({{2015, 1, 1}, {0, 0, 0}}, "America/Chicago"),
                 Timex.to_datetime({{2020, 12, 31}, {23, 59, 59}}, "America/Chicago")
               }
    end

    test "for a start, end and a user timezone" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "range" => "year",
            "timezone" => "America/Chicago",
            "start" => "2015",
            "end" => "2020"
          }),
          NewUserTrend
        )

      assert Trend.get_aggregate_datetimes(request, "America/Chicago") ==
               {
                 Timex.to_datetime({{2015, 1, 1}, {0, 0, 0}}, "America/Chicago"),
                 Timex.to_datetime({{2020, 12, 31}, {23, 59, 59}}, "America/Chicago")
               }
    end

    test "for a year range with a user override" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "range" => "year",
            "timezone" => "America/Chicago",
            "start" => "2015",
            "end" => "2017"
          }),
          NewUserTrend
        )

      assert Trend.get_aggregate_datetimes(request, "America/New_York") ==
               {
                 Timex.to_datetime({{2015, 1, 1}, {0, 0, 0}}, "America/New_York"),
                 Timex.to_datetime({{2017, 12, 31}, {23, 59, 59}}, "America/New_York")
               }
    end

    test "for a month range with UTC" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "range" => "month",
            "start" => "1989-03",
            "end" => "1992-05"
          }),
          NewUserTrend
        )

      assert Trend.get_aggregate_datetimes(request, "Etc/UTC") ==
               {
                 Timex.to_datetime({{1989, 3, 1}, {0, 0, 0}}, "Etc/UTC"),
                 Timex.to_datetime({{1992, 5, 31}, {23, 59, 59}}, "Etc/UTC")
               }
    end

    test "for a month range with a user timezone" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "range" => "month",
            "timezone" => "America/Chicago",
            "start" => "1989-04",
            "end" => "1989-05"
          }),
          NewUserTrend
        )

      assert Trend.get_aggregate_datetimes(request, "America/Chicago") ==
               {
                 Timex.to_datetime({{1989, 4, 1}, {0, 0, 0}}, "America/Chicago"),
                 Timex.to_datetime({{1989, 5, 31}, {23, 59, 59}}, "America/Chicago")
               }
    end

    test "for a month range with a user override" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "range" => "month",
            "timezone" => "America/Chicago",
            "start" => "1989-04",
            "end" => "1989-05"
          }),
          NewUserTrend
        )

      assert Trend.get_aggregate_datetimes(request, "America/New_York") ==
               {
                 Timex.to_datetime({{1989, 4, 1}, {0, 0, 0}}, "America/New_York"),
                 Timex.to_datetime({{1989, 5, 31}, {23, 59, 59}}, "America/New_York")
               }
    end

    test "for a week range with UTC" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "range" => "week",
            "start" => "2020-07-15"
          }),
          NewUserTrend
        )

      assert Trend.get_aggregate_datetimes(request, "Etc/UTC") ==
               {
                 ~U[2020-07-13 00:00:00Z],
                 DateTime.now!("Etc/UTC") |> DateTime.truncate(:second) |> Timex.end_of_week()
               }
    end

    test "for a week range with a user timezone" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "range" => "week",
            "timezone" => "America/Chicago",
            "start" => "2020-07-13",
            "end" => "2020-07-20"
          }),
          NewUserTrend
        )

      assert Trend.get_aggregate_datetimes(request, "America/Chicago") ==
               {
                 Timex.to_datetime({{2020, 7, 13}, {0, 0, 0}}, "America/Chicago"),
                 Timex.to_datetime({{2020, 7, 26}, {23, 59, 59}}, "America/Chicago")
               }
    end

    test "for a day range with a user timezone" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "range" => "day",
            "timezone" => "America/Chicago",
            "start" => "2020-07-06",
            "end" => "2020-07-10"
          }),
          NewUserTrend
        )

      assert Trend.get_aggregate_datetimes(request, "America/Chicago") ==
               {
                 Timex.to_datetime({{2020, 7, 06}, {0, 0, 0}}, "America/Chicago"),
                 Timex.to_datetime({{2020, 7, 10}, {23, 59, 59}}, "America/Chicago")
               }
    end

    test "for a hour range with a user timezone" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "range" => "hour",
            "timezone" => "America/Chicago",
            "start" => "2020-07-06 12:05:17",
            "end" => "2020-07-06 20:31:30"
          }),
          NewUserTrend
        )

      assert Trend.get_aggregate_datetimes(request, "America/Chicago") ==
               {
                 Timex.to_datetime({{2020, 7, 06}, {12, 0, 0}}, "America/Chicago"),
                 Timex.to_datetime({{2020, 7, 06}, {20, 59, 59}}, "America/Chicago")
               }
    end

    test "for a minute range with a user timezone" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "range" => "minute",
            "timezone" => "America/Chicago",
            "start" => "2020-07-06 12:05:17",
            "end" => "2020-07-06 15:15:45"
          }),
          NewUserTrend
        )

      assert Trend.get_aggregate_datetimes(request, "America/Chicago") ==
               {
                 Timex.to_datetime({{2020, 7, 06}, {12, 5, 0}}, "America/Chicago"),
                 Timex.to_datetime({{2020, 7, 06}, {15, 15, 59}}, "America/Chicago")
               }
    end
  end

  describe "get_possible_results/4" do
    test "returns a single year for start and stop dates" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "range" => "year",
            "start" => "2016",
            "end" => "2016"
          }),
          NewUserTrend
        )

      {start_dt, end_dt} = Trend.get_aggregate_datetimes(request, "Etc/UTC")

      assert ["2016"] == Trend.get_possible_results(start_dt, end_dt, request, false)
    end

    test "returns a range of years for start and stop dates" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "range" => "year",
            "start" => "2016",
            "end" => "2020"
          }),
          NewUserTrend
        )

      {start_dt, end_dt} = Trend.get_aggregate_datetimes(request, "Etc/UTC")

      assert ["2016", "2017", "2018", "2019", "2020"] ==
               Trend.get_possible_results(start_dt, end_dt, request, false)
    end
  end

  describe "to_result_date/2" do
    test "returns the date in the correct formats for it's unit in its timezone" do
      dt = Timex.to_datetime({{2020, 7, 06}, {15, 5, 0}}, "America/Chicago")
      assert Trend.to_result_date(dt, "year", false) == "2020"
      assert Trend.to_result_date(dt, "month", false) == "July 2020"
      assert Trend.to_result_date(dt, "week", false) == "July 6 - July 13"
      assert Trend.to_result_date(dt, "day", false) == "July 6 2020"
      assert Trend.to_result_date(dt, "hour", true) == "July 6 2020 3:00 pm"
      assert Trend.to_result_date(dt, "hour", false) == "July 6 2020 15:00"
      assert Trend.to_result_date(dt, "minute", true) == "July 6 2020 3:05 pm"
      assert Trend.to_result_date(dt, "minute", false) == "July 6 2020 15:05"
    end
  end

  describe "format_result_date/3" do
    test "year unit" do
      result =
        %{date_result: "2020", aggregate: 5}
        |> Trend.format_result_data("year", false)

      assert result == {"2020", 5}
    end

    test "month unit" do
      result =
        %{date_result: "2020-01", aggregate: 5}
        |> Trend.format_result_data("month", false)

      assert result == {"January 2020", 5}
    end

    test "week unit" do
      result =
        %{date_result: "2020-10", aggregate: 5}
        |> Trend.format_result_data("week", false)

      assert result == {"March 2 - March 8", 5}
    end

    test "day unit" do
      result =
        %{date_result: "2020-07-06", aggregate: 5}
        |> Trend.format_result_data("day", false)

      assert result == {"July 6 2020", 5}
    end

    test "hour unit with 12hr time" do
      result =
        %{date_result: "2020-07-06 13:00", aggregate: 5}
        |> Trend.format_result_data("hour", true)

      assert result == {"July 6 2020 1:00 pm", 5}
    end

    test "hour unit with 24hr time" do
      result =
        %{date_result: "2020-07-06 13:00", aggregate: 5}
        |> Trend.format_result_data("hour", false)

      assert result == {"July 6 2020 13:00", 5}
    end

    test "minute unit with 12hr time" do
      result =
        %{date_result: "2020-07-06 13:07:00", aggregate: 5}
        |> Trend.format_result_data("minute", true)

      assert result == {"July 6 2020 1:07 pm", 5}
    end

    test "minute unit with 24hr time" do
      result =
        %{date_result: "2020-07-06 13:42:00", aggregate: 5}
        |> Trend.format_result_data("minute", false)

      assert result == {"July 6 2020 13:42", 5}
    end
  end

  describe "between/2" do
    test "converts DateTimes with Timezones into naive time zones" do
      start = Timex.to_datetime({{2020, 7, 06}, {15, 5, 0}}, "America/Chicago")
      utc = Timezone.get("Etc/UTC")
      insert_at = Timezone.convert(start, utc)
      u = insert(:user, inserted_at: insert_at |> Timex.shift(minutes: 10))
      insert(:user, inserted_at: insert_at |> Timex.shift(minutes: -10))

      result =
        User
        |> Trend.between(
          start_dt: start,
          end_dt: start |> Timex.shift(hours: 1),
          metric: NewUserTrend
        )
        |> Repo.all()

      assert result == [u]
    end
  end

  describe "aggregate_as/3" do
    test "builds an aggregate with a select" do
      insert(:user)

      result =
        User
        |> group_by([q], q.id)
        |> Trend.aggregate_as(:count, :id)
        |> Repo.all()

      assert result == [%{aggregate: 1}]
    end
  end
end
