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
      conn = build_conn(:get, "/api/metrics/new_users")
      resp = MetricResponder.get(conn, "new_users")
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
      conn = build_conn(:get, "/api/resources/users/metrics/foo")
      resp = MetricResponder.resource_index(conn, "users", "foo")
      assert resp.status == 404
    end

    @tag manifest: DefaultManifest
    test "returns a metric" do
      conn = build_conn(:get, "/api/resources/users/metrics/new_users")
      resp = MetricResponder.resource_index(conn, "users", "new_users")
      assert resp.status == 200
    end
  end
end
