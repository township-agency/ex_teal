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
    with {:ok, dashboard} <- ExTeal.dashboard_for(name) do
      cards = Dashboard.cards_to_json(dashboard, conn)
      {:ok, body} = Jason.encode(cards)
      Serializer.as_json(conn, body, 200)
    else
      {:error, reason} -> ErrorSerializer.handle_error(conn, reason)
    end
  end

  def resource(conn, resource_name) do
    with {:ok, resource} <- ExTeal.resource_for(resource_name) do
      cards = Dashboard.cards_to_json(resource, conn)
      {:ok, body} = Jason.encode(cards)
      Serializer.as_json(conn, body, 200)
    else
      {:error, reason} -> ErrorSerializer.handle_error(conn, reason)
    end
  end
end
