defmodule ExTeal.Metric.RangesTest do
  use TestExTeal.ConnCase
  use Timex
  alias ExTeal.Metric.{Ranges, Request}

  describe "get_aggregate_datetimes/2" do
    test "for a year unit with UTC" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "unit" => "year",
            "start_at" => "2016",
            "end_at" => "2016"
          })
        )

      assert Ranges.get_aggregate_datetimes(request, "Etc/UTC") ==
               {~U[2016-01-01 00:00:00Z], ~U[2016-12-31 23:59:59Z]}
    end

    test "for a start year and a user timezone" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "unit" => "year",
            "timezone" => "America/Chicago",
            "start_at" => "2015",
            "end_at" => "2020"
          })
        )

      assert Ranges.get_aggregate_datetimes(request, "America/Chicago") ==
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
            "unit" => "year",
            "timezone" => "America/Chicago",
            "start_at" => "2015",
            "end_at" => "2020"
          })
        )

      assert Ranges.get_aggregate_datetimes(request, "America/Chicago") ==
               {
                 Timex.to_datetime({{2015, 1, 1}, {0, 0, 0}}, "America/Chicago"),
                 Timex.to_datetime({{2020, 12, 31}, {23, 59, 59}}, "America/Chicago")
               }
    end

    test "for a year unit with a user override" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "unit" => "year",
            "timezone" => "America/Chicago",
            "start_at" => "2015",
            "end_at" => "2017"
          })
        )

      assert Ranges.get_aggregate_datetimes(request, "America/New_York") ==
               {
                 Timex.to_datetime({{2015, 1, 1}, {0, 0, 0}}, "America/New_York"),
                 Timex.to_datetime({{2017, 12, 31}, {23, 59, 59}}, "America/New_York")
               }
    end

    test "for a month unit with UTC" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "unit" => "month",
            "start_at" => "1989-03",
            "end_at" => "1992-05"
          })
        )

      assert Ranges.get_aggregate_datetimes(request, "Etc/UTC") ==
               {
                 Timex.to_datetime({{1989, 3, 1}, {0, 0, 0}}, "Etc/UTC"),
                 Timex.to_datetime({{1992, 5, 31}, {23, 59, 59}}, "Etc/UTC")
               }
    end

    test "for a month unit with a user timezone" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "unit" => "month",
            "timezone" => "America/Chicago",
            "start_at" => "1989-04",
            "end_at" => "1989-05"
          })
        )

      assert Ranges.get_aggregate_datetimes(request, "America/Chicago") ==
               {
                 Timex.to_datetime({{1989, 4, 1}, {0, 0, 0}}, "America/Chicago"),
                 Timex.to_datetime({{1989, 5, 31}, {23, 59, 59}}, "America/Chicago")
               }
    end

    test "for a month unit with a user override" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "unit" => "month",
            "timezone" => "America/Chicago",
            "start_at" => "1989-04",
            "end_at" => "1989-05"
          })
        )

      assert Ranges.get_aggregate_datetimes(request, "America/New_York") ==
               {
                 Timex.to_datetime({{1989, 4, 1}, {0, 0, 0}}, "America/New_York"),
                 Timex.to_datetime({{1989, 5, 31}, {23, 59, 59}}, "America/New_York")
               }
    end

    test "for a week unit with UTC" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "unit" => "week",
            "start_at" => "2020-07-15",
            "end_at" => "2020-07-20"
          })
        )

      assert Ranges.get_aggregate_datetimes(request, "Etc/UTC") ==
               {
                 ~U[2020-07-13 00:00:00Z],
                 ~U[2020-07-26 23:59:59Z]
               }
    end

    test "for a week unit with a user timezone" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "unit" => "week",
            "timezone" => "America/Chicago",
            "start_at" => "2020-07-13",
            "end_at" => "2020-07-20"
          })
        )

      assert Ranges.get_aggregate_datetimes(request, "America/Chicago") ==
               {
                 Timex.to_datetime({{2020, 7, 13}, {0, 0, 0}}, "America/Chicago"),
                 Timex.to_datetime({{2020, 7, 26}, {23, 59, 59}}, "America/Chicago")
               }
    end

    test "for a day unit with a user timezone" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "unit" => "day",
            "timezone" => "America/Chicago",
            "start_at" => "2020-07-06",
            "end_at" => "2020-07-10"
          })
        )

      assert Ranges.get_aggregate_datetimes(request, "America/Chicago") ==
               {
                 Timex.to_datetime({{2020, 7, 06}, {0, 0, 0}}, "America/Chicago"),
                 Timex.to_datetime({{2020, 7, 10}, {23, 59, 59}}, "America/Chicago")
               }
    end

    test "for a hour unit with a user timezone" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "unit" => "hour",
            "timezone" => "America/Chicago",
            "start_at" => "2020-07-06 12:05:17",
            "end_at" => "2020-07-06 20:31:30"
          })
        )

      assert Ranges.get_aggregate_datetimes(request, "America/Chicago") ==
               {
                 Timex.to_datetime({{2020, 7, 06}, {12, 0, 0}}, "America/Chicago"),
                 Timex.to_datetime({{2020, 7, 06}, {20, 59, 59}}, "America/Chicago")
               }
    end

    test "for a minute unit with a user timezone" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "unit" => "minute",
            "timezone" => "America/Chicago",
            "start_at" => "2020-07-06 12:05:17",
            "end_at" => "2020-07-06 15:15:45"
          })
        )

      assert Ranges.get_aggregate_datetimes(request, "America/Chicago") ==
               {
                 Timex.to_datetime({{2020, 7, 06}, {12, 5, 0}}, "America/Chicago"),
                 Timex.to_datetime({{2020, 7, 06}, {15, 15, 59}}, "America/Chicago")
               }
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
        TestExTeal.User
        |> Ranges.between(
          start_dt: start,
          end_dt: start |> Timex.shift(hours: 1),
          metric: TestExTeal.NewUserTrend
        )
        |> Repo.all()

      assert result == [u]
    end
  end
end
