defmodule ExTeal.Metric.TrendTest do
  use TestExTeal.ConnCase
  use Timex

  alias ExTeal.Metric.{Request, Trend}
  alias TestExTeal.NewUserTrend

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
end
