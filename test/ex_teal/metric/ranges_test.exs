defmodule ExTeal.Metric.RangesTest do
  use TestExTeal.ConnCase
  use Timex
  alias ExTeal.Metric.{Ranges, Request}

  @utc_params %{
    "uri" => "new-user-trend",
    "unit" => "year",
    "start_at" => "2016-01-05T02:03:44-00:00",
    "end_at" => "2016-03-06T02:04:56-00:00"
  }

  @central_params %{
    "uri" => "new-user-trend",
    "unit" => "year",
    "start_at" => "2016-01-05T02:03:44-06:00",
    "end_at" => "2016-03-06T02:04:56-06:00"
  }

  setup context do
    params = if context[:utc], do: @utc_params, else: @central_params

    params = if context[:unit], do: Map.put(params, "unit", context[:unit]), else: params

    {:ok, request: Request.from_conn(build_conn(:get, "foo", params))}
  end

  describe "get_aggregate_datetimes/2" do
    @tag utc: true
    test "for a year unit with UTC", %{request: request} do
      assert Ranges.get_aggregate_datetimes(request) ==
               {~U[2016-01-01 00:00:00Z], ~U[2016-12-31 23:59:59Z]}
    end

    test "for a start year and a user timezone", %{request: request} do
      assert Ranges.get_aggregate_datetimes(request) ==
               {
                 Timex.to_datetime({{2016, 1, 1}, {0, 0, 0}}, "Etc/GMT+6"),
                 Timex.to_datetime({{2016, 12, 31}, {23, 59, 59}}, "Etc/GMT+6")
               }
    end

    @tag utc: true, unit: "month"
    test "for a month unit with UTC", %{request: request} do
      assert Ranges.get_aggregate_datetimes(request) ==
               {~U[2016-01-01 00:00:00Z], ~U[2016-03-31 23:59:59Z]}
    end

    @tag unit: "month"
    test "for a month unit with a user timezone", %{request: request} do
      assert Ranges.get_aggregate_datetimes(request) == {
               Timex.to_datetime({{2016, 1, 1}, {0, 0, 0}}, "Etc/GMT+6"),
               Timex.to_datetime({{2016, 3, 31}, {23, 59, 59}}, "Etc/GMT+6")
             }
    end

    @tag utc: true, unit: "week"
    test "for a week unit with UTC", %{request: request} do
      assert Ranges.get_aggregate_datetimes(request) ==
               {~U[2016-01-04 00:00:00Z], ~U[2016-03-06 23:59:59Z]}
    end

    @tag unit: "week"
    test "for a week unit with a user timezone", %{request: request} do
      assert Ranges.get_aggregate_datetimes(request) ==
               {
                 Timex.to_datetime({{2016, 1, 4}, {0, 0, 0}}, "Etc/GMT+6"),
                 Timex.to_datetime({{2016, 3, 6}, {23, 59, 59}}, "Etc/GMT+6")
               }
    end

    @tag unit: "day"
    test "for a day unit with a user timezone", %{request: request} do
      assert Ranges.get_aggregate_datetimes(request) ==
               {
                 Timex.to_datetime({{2016, 1, 5}, {0, 0, 0}}, "Etc/GMT+6"),
                 Timex.to_datetime({{2016, 3, 6}, {23, 59, 59}}, "Etc/GMT+6")
               }
    end

    @tag unit: "hour"
    test "for a hour unit with a user timezone", %{request: request} do
      assert Ranges.get_aggregate_datetimes(request) ==
               {
                 Timex.to_datetime({{2016, 1, 5}, {2, 0, 0}}, "Etc/GMT+6"),
                 Timex.to_datetime({{2016, 3, 6}, {2, 59, 59}}, "Etc/GMT+6")
               }
    end

    @tag unit: "minute"
    test "for a minute unit with a user timezone", %{request: request} do
      assert Ranges.get_aggregate_datetimes(request) ==
               {
                 Timex.to_datetime({{2016, 1, 5}, {2, 3, 0}}, "Etc/GMT+6"),
                 Timex.to_datetime({{2016, 3, 6}, {2, 4, 59}}, "Etc/GMT+6")
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

  @dt_format "{YYYY}-{0M}-{0D} {h24}:{m}:{s}"

  describe "parse_dt/3" do
    test "parses a param in the timezone it's given, falling back to UTC" do
      start = Timex.to_datetime({{2020, 7, 06}, {15, 5, 0}}, "America/Chicago")

      assert start == Ranges.parse_dt("2020-07-06 15:05:00", @dt_format, "America/Chicago")
    end
  end
end
