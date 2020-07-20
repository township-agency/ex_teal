defmodule ExTeal.Api.MetricResponderTest do
  use TestExTeal.ConnCase

  alias ExTeal.Api.MetricResponder
  alias TestExTeal.{DefaultManifest, EmptyManifest, MetricManifest}

  describe "get/2" do
    @tag manifest: EmptyManifest
    test "returns a 404 for an empty manifest" do
      conn = build_conn(:get, "/api/metrics/foo")
      resp = MetricResponder.get(conn, "foo")
      assert resp.status == 404
    end

    @tag manifest: DefaultManifest
    test "returns a 404 for an invalid metric" do
      conn = build_conn(:get, "/api/metrics/foo")
      resp = MetricResponder.get(conn, "foo")
      assert resp.status == 404
    end

    @tag manifest: MetricManifest
    test "returns a 200 for an valid metric" do
      conn = build_conn(:get, "/api/metrics/new_users", params())
      resp = MetricResponder.get(conn, "new_users")
      assert resp.status == 200
    end

    @tag manifest: MetricManifest
    test "returns a 200 for a valid multi metric" do
      conn = build_conn(:get, "/api/metrics/revenue_trend", params())
      resp = MetricResponder.get(conn, "revenue_trend")
      body = Jason.decode!(resp.resp_body, keys: :atoms)
      assert Enum.count(body.metric.data) == 2
      assert resp.status == 200
    end
  end

  describe "resource_index/3" do
    @tag manifest: EmptyManifest
    test "returns a 404 for an empty manifest" do
      conn = build_conn(:get, "/api/resources/users/metrics/new_users")
      resp = MetricResponder.resource_index(conn, "users", "new_users")
      assert resp.status == 404
    end

    @tag manifest: DefaultManifest
    test "returns a 404 for an invalid resource" do
      conn = build_conn(:get, "/api/resources/foo/metrics/new_users")
      resp = MetricResponder.resource_index(conn, "foo", "new_users")
      assert resp.status == 404
    end

    @tag manifest: DefaultManifest
    test "returns a 404 for an invalid metric" do
      conn = build_conn(:get, "/api/resources/users/metrics/foo", params())
      resp = MetricResponder.resource_index(conn, "users", "foo")
      assert resp.status == 404
    end

    @tag manifest: DefaultManifest
    test "returns a metric" do
      conn = build_conn(:get, "/api/resources/users/metrics/new_users", params())
      resp = MetricResponder.resource_index(conn, "users", "new_users")
      assert resp.status == 200
    end
  end

  def params,
    do: %{
      "uri" => "new-user-trend",
      "unit" => "year",
      "start_at" => "2016-01-05T02:03:44-00:00",
      "end_at" => "2016-03-06T02:04:56-00:00"
    }
end
