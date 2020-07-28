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
        dashboard
        |> Dashboard.cards_to_json(conn)
        |> as_json(conn)

      {:error, reason} ->
        ErrorSerializer.handle_error(conn, reason)
    end
  end

  def resource(conn, resource_name) do
    case ExTeal.resource_for(resource_name) do
      {:ok, resource} ->
        resource
        |> Dashboard.cards_to_json(conn)
        |> as_json(conn)

      {:error, reason} ->
        ErrorSerializer.handle_error(conn, reason)
    end
  end

  defp as_json(cards, conn) do
    {:ok, body} = Jason.encode(cards)
    Serializer.as_json(conn, body, 200)
  end
end
