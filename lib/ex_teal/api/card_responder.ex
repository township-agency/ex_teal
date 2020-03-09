defmodule ExTeal.Api.CardResponder do
  @moduledoc """
  API Responder that manages cards
  - `GET /dashboard/:name` - Return the dashboard and it's cards
  - `GET /resource/:resource_name/cards` - Return the cards for a resource
  """

  alias ExTeal.Api.ErrorSerializer
  alias ExTeal.Dashboard
  alias ExTeal.Resource.Serializer

  def dashboard(conn, name) do
    case ExTeal.dashboard_for(name) do
      {:ok, dashboard} ->
        cards = Dashboard.cards_to_json(dashboard, conn)
        {:ok, body} = Jason.encode(cards)
        Serializer.as_json(conn, body, 200)

      {:error, reason} ->
        ErrorSerializer.handle_error(conn, reason)
    end
  end

  def resource(conn, resource_name) do
    case ExTeal.resource_for(resource_name) do
      {:ok, resource} ->
        cards = Dashboard.cards_to_json(resource, conn)
        {:ok, body} = Jason.encode(cards)
        Serializer.as_json(conn, body, 200)

      {:error, reason} ->
        ErrorSerializer.handle_error(conn, reason)
    end
  end
end
