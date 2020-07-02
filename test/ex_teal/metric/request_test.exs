defmodule ExTeal.Metric.RequestTest do
  use TestExTeal.ConnCase

  alias ExTeal.Metric.Request
  alias TestExTeal.NewUserTrend

  describe "resolve_timezone/1" do
    test "fetches the timezone from the request conn" do
      tz = "America/Chicago"
      conn = build_conn(:get, "foo", %{"timezone" => tz, "range" => "foo"})

      assert tz == Request.resolve_timezone(conn)
    end

    test "falls back to utc time" do
      conn = build_conn(:get, "foo", %{"range" => "foo"})

      assert "Etc/UTC" == Request.resolve_timezone(conn)
    end

    test "can be overriden by an application config" do
      conn = build_conn(:get, "foo", %{"timezone" => "America/Chicago", "range" => "foo"})
      Application.put_env(:ex_teal, :user_timezone_override, "America/New_York")
      assert "America/New_York" == Request.resolve_timezone(conn)
      Application.put_env(:ex_teal, :user_timezone_override, nil)
    end
  end
end
