defmodule ExTeal.Metric.TrendTest do
  use TestExTeal.ConnCase
  use Timex
  import Ecto.Query

  alias Decimal, as: D
  alias ExTeal.Metric.{Ranges, Request, Trend}
  alias TestExTeal.{NewUserTrend, RevenueTrend}
  alias TestExTeal.{Order, User}

  describe "aggregate/5" do
    test "returns data by year" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "unit" => "year",
            "start_at" => "2016-01-03T00:00:00-04:00",
            "end_at" => "2017-12-30T23:59:59-04:00"
          })
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
            "unit" => "month",
            "start_at" => "2020-01",
            "end_at" => "2020-04"
          })
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
            "unit" => "week",
            "start_at" => "2020-01",
            "end_at" => "2020-02"
          })
        )

      insert(:order, grand_total: 100, inserted_at: from_erl({{2020, 1, 1}, {0, 0, 0}}))
      insert_pair(:order, grand_total: 23, inserted_at: from_erl({{2020, 1, 6}, {0, 0, 0}}))

      result = Trend.aggregate(RevenueTrend, request, Order, :sum, :grand_total)

      assert result == [
               %{date: "December 30 - January 5", value: D.new(100)},
               %{date: "January 6 - January 12", value: D.new(46)}
             ]
    end

    test "can return sums by the minute" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "revenue-trend",
            "unit" => "minute",
            # These are in EST
            "start_at" => "2020-01-01 10:00:00",
            "end_at" => "2020-01-01 10:04:00",
            "timezone" => "America/New_York"
          })
        )

      insert(:order, grand_total: 100, inserted_at: from_erl({{2020, 1, 1}, {13, 2, 0}}))
      insert_pair(:order, grand_total: 23, inserted_at: from_erl({{2020, 1, 1}, {13, 3, 0}}))

      result = Trend.aggregate(RevenueTrend, request, Order, :sum, :grand_total)

      zero = Decimal.new(0)

      assert result == [
               %{date: "January 1 2020 10:00", value: zero},
               %{date: "January 1 2020 10:01", value: zero},
               %{date: "January 1 2020 10:02", value: zero},
               %{date: "January 1 2020 10:03", value: Decimal.new(100)},
               %{date: "January 1 2020 10:04", value: Decimal.new(46)}
             ]
    end
  end

  def from_erl(erl, tz \\ "Etc/UTC") do
    erl
    |> NaiveDateTime.from_erl!()
    |> DateTime.from_naive!(tz)
  end

  describe "get_possible_results/4" do
    test "returns a single year for start and stop dates" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "unit" => "year",
            "start_at" => "2016",
            "end_at" => "2016"
          })
        )

      {start_dt, end_dt} = Ranges.get_aggregate_datetimes(request, "Etc/UTC")

      assert ["2016"] == Trend.get_possible_results(start_dt, end_dt, request, false)
    end

    test "returns a unit of years for start and stop dates" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "unit" => "year",
            "start_at" => "2016",
            "end_at" => "2020"
          })
        )

      {start_dt, end_dt} = Ranges.get_aggregate_datetimes(request, "Etc/UTC")

      assert ["2016", "2017", "2018", "2019", "2020"] ==
               Trend.get_possible_results(start_dt, end_dt, request, false)
    end

    test "returns a unit of minutes for start and stop dates" do
      request =
        Request.from_conn(
          build_conn(:get, "/foo", %{
            "uri" => "new-user-trend",
            "unit" => "minute",
            "start_at" => "2020-01-01 03:45:00",
            "end_at" => "2020-01-01 03:47:00"
          })
        )

      {start_dt, end_dt} = Ranges.get_aggregate_datetimes(request, "America/Chicago")

      assert ["January 1 2020 03:45:00", "January 1 2020 03:46:00", "January 1 2020 03:47:00"] ==
               Trend.get_possible_results(start_dt, end_dt, request, false)
    end
  end

  describe "to_result_date/3" do
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
        |> Trend.format_result_data("year", "America/Chicago", false)

      assert result == {"2020", 5}
    end

    test "month unit" do
      result =
        %{date_result: "2020-01", aggregate: 5}
        |> Trend.format_result_data("month", "America/Chicago", false)

      assert result == {"January 2020", 5}
    end

    test "week unit" do
      result =
        %{date_result: "2020-10", aggregate: 5}
        |> Trend.format_result_data("week", "America/Chicago", false)

      assert result == {"March 2 - March 8", 5}
    end

    test "day unit" do
      result =
        %{date_result: "2020-07-06", aggregate: 5}
        |> Trend.format_result_data("day", "America/Chicago", false)

      assert result == {"July 6 2020", 5}
    end

    test "hour unit with 12hr time" do
      result =
        %{date_result: "2020-07-06 13:00", aggregate: 5}
        |> Trend.format_result_data("hour", "America/Chicago", true)

      assert result == {"July 6 2020 1:00 pm", 5}
    end

    test "hour unit with 24hr time" do
      result =
        %{date_result: "2020-07-06 13:00", aggregate: 5}
        |> Trend.format_result_data("hour", "America/Chicago", false)

      assert result == {"July 6 2020 13:00", 5}
    end

    test "minute unit with 12hr time" do
      result =
        %{date_result: "2020-07-06 13:07:00", aggregate: 5}
        |> Trend.format_result_data("minute", "America/Chicago", true)

      assert result == {"July 6 2020 1:07 pm", 5}
    end

    test "minute unit with 24hr time" do
      result =
        %{date_result: "2020-07-06 13:42:00", aggregate: 5}
        |> Trend.format_result_data("minute", "America/Chicago", false)

      assert result == {"July 6 2020 13:42", 5}
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

  defp as_iso
end
