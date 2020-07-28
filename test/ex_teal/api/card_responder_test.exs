defmodule ExTeal.Api.CardResponderTest do
  use TestExTeal.ConnCase

  alias ExTeal.Api.CardResponder
  alias TestExTeal.{DefaultManifest, EmptyManifest, MetricManifest}

  describe "dashboard/2" do
    @tag manifest: EmptyManifest
    test "returns the default cards for an empty manifest" do
      conn = build_conn(:get, "/api/dashboards/main")
      resp = CardResponder.dashboard(conn, "main")
      assert resp.status == 200
      card = response_card(resp)
      assert card.component == "help-card"
    end

    @tag manifest: DefaultManifest
    test "returns a 404 for an invalid metric" do
      conn = build_conn(:get, "/api/dashboards/foo")
      resp = CardResponder.dashboard(conn, "foo")
      assert resp.status == 404
    end

    @tag manifest: MetricManifest
    test "returns a 200 for an valid metric" do
      conn = build_conn(:get, "/api/dashboards/main")
      resp = CardResponder.dashboard(conn, "main_dashboards")
      assert resp.status == 200
      card = response_card(resp)
      assert card.component == "value-metric"
    end
  end

  describe "resource/2" do
    @tag manifest: EmptyManifest
    test "returns a 404 for a missing resource for an empty manifest" do
      conn = build_conn(:get, "/api/resource/foo/cards")
      resp = CardResponder.resource(conn, "foo")
      assert resp.status == 404
    end

    @tag manifest: DefaultManifest
    test "returns a empty list for a resource without cards" do
      conn = build_conn(:get, "/api/resource/posts/cards")
      resp = CardResponder.resource(conn, "posts")
      assert resp.status == 200
      {:ok, body} = Jason.decode(resp.resp_body, keys: :atoms)
      assert body.cards == []
    end

    @tag manifest: DefaultManifest
    test "returns the cards for a resource" do
      conn = build_conn(:get, "/api/resources/users/cards")
      resp = CardResponder.resource(conn, "users")
      assert resp.status == 200
      card = response_card(resp)
      assert card.component == "value-metric"
      assert card.title == "New users metric"
    end
  end

  defp response_card(resp) do
    {:ok, body} = Jason.decode(resp.resp_body, keys: :atoms)
    %{cards: [first_card | _]} = body
    first_card
  end
end
