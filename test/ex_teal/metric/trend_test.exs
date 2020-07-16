defmodule ExTeal.Metric.TrendTest do
  use TestExTeal.ConnCase
  use Timex
  import Ecto.Query

  alias Decimal, as: D
  alias ExTeal.Metric.{Ranges, Request, Trend}
  alias TestExTeal.{NewUserTrend, RevenueTrend}
  alias TestExTeal.{Order, User}

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
    params = if context[:end], do: Map.put(params, "end_at", context[:end]), else: params

    {:ok, request: Request.from_conn(build_conn(:get, "foo", params))}
  end

  describe "aggregate/5" do
    @tag utc: true
    test "returns data by year in utc", %{request: request} do
      insert(:user, inserted_at: from_erl({{2017, 1, 5}, {0, 0, 0}}))

      result = Trend.aggregate(NewUserTrend, request, User, :count, :id)

      assert result == [
               %{date: "2016", value: D.new(0)}
             ]
    end

    @tag end: "2017-03-06T02:04:56-06:00"
    test "returns data by year", %{request: request} do
      insert(:user, inserted_at: from_erl({{2017, 1, 5}, {0, 0, 0}}))

      result = Trend.aggregate(NewUserTrend, request, User, :count, :id)

      assert result == [
               %{date: "2016", value: D.new(0)},
               %{date: "2017", value: D.new(1)}
             ]
    end

    @tag end: "2016-04-06T02:04:56-06:00", unit: "month"
    test "returns data by month", %{request: request} do
      insert(:user, inserted_at: from_erl({{2016, 1, 5}, {0, 0, 0}}))
      insert_pair(:user, inserted_at: from_erl({{2016, 3, 5}, {0, 0, 0}}))

      result = Trend.aggregate(NewUserTrend, request, User, :count, :id)

      assert result == [
               %{date: "January 2016", value: D.new(1)},
               %{date: "February 2016", value: D.new(0)},
               %{date: "March 2016", value: D.new(2)},
               %{date: "April 2016", value: D.new(0)}
             ]
    end

    @tag end: "2016-01-11T02:04:56-06:00", unit: "week"
    test "can return sum aggregations by week", %{request: request} do
      insert(:order, grand_total: 100, inserted_at: from_erl({{2016, 1, 5}, {10, 0, 0}}))
      insert_pair(:order, grand_total: 23, inserted_at: from_erl({{2016, 1, 13}, {0, 0, 0}}))

      result = Trend.aggregate(RevenueTrend, request, Order, :sum, :grand_total)

      assert result == [
               %{date: "January 4 - January 10", value: D.new(100)},
               %{date: "January 11 - January 17", value: D.new(46)}
             ]
    end

    @tag end: "2016-01-05T02:06:44-06:00", unit: "minute"
    test "can return sums by the minute", %{request: request} do
      insert(:order,
        grand_total: 100,
        inserted_at: from_erl({{2016, 1, 5}, {8, 3, 2}}, "America/Chicago")
      )

      insert_pair(:order,
        grand_total: 23,
        inserted_at: from_erl({{2016, 1, 5}, {8, 4, 0}}, "America/Chicago")
      )

      result = Trend.aggregate(RevenueTrend, request, Order, :sum, :grand_total)

      zero = Decimal.new(0)

      assert result == [
               %{date: "January 5 2016 02:03", value: Decimal.new(100)},
               %{date: "January 5 2016 02:04", value: Decimal.new(46)},
               %{date: "January 5 2016 02:05", value: zero},
               %{date: "January 5 2016 02:06", value: zero}
             ]
    end
  end

  def from_erl(erl, tz \\ "Etc/UTC") do
    erl
    |> NaiveDateTime.from_erl!()
    |> DateTime.from_naive!(tz)
  end

  describe "get_possible_results/4" do
    test "returns a single year", %{request: request} do
      {start_dt, end_dt} = Ranges.get_aggregate_datetimes(request)

      assert ["2016"] ==
               Trend.get_possible_results(start_dt, end_dt, request, "America/New_York", false)
    end

    @tag end: "2020-01-05T02:06:44-06:00"
    test "returns a unit of years", %{request: request} do
      {start_dt, end_dt} = Ranges.get_aggregate_datetimes(request)

      assert ["2016", "2017", "2018", "2019", "2020"] ==
               Trend.get_possible_results(start_dt, end_dt, request, "America/Chicago", false)
    end

    @tag end: "2016-01-05T02:06:44-06:00", unit: "minute"
    test "returns a unit of minutess", %{request: request} do
      {start_dt, end_dt} = Ranges.get_aggregate_datetimes(request)

      assert Trend.get_possible_results(start_dt, end_dt, request, "America/Chicago", false) ==
               [
                 "January 5 2016 02:03",
                 "January 5 2016 02:04",
                 "January 5 2016 02:05",
                 "January 5 2016 02:06"
               ]
    end
  end

  describe "to_result_date/3" do
    test "returns the date in the correct formats for it's unit in its timezone" do
      dt = Timex.to_datetime({{2020, 7, 06}, {15, 5, 0}}, "America/Chicago")
      assert Trend.to_result_date(dt, "year", false) == "2020"
      assert Trend.to_result_date(dt, "month", false) == "July 2020"
      assert Trend.to_result_date(dt, "week", false) == "July 6 - July 12"
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
        %{date_result: "2020-07-06 13:07", aggregate: 5}
        |> Trend.format_result_data("minute", "America/Chicago", true)

      assert result == {"July 6 2020 1:07 pm", 5}
    end

    test "minute unit with 24hr time" do
      result =
        %{date_result: "2020-07-06 13:42", aggregate: 5}
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
end
