defmodule ExTeal.IndexPage do
  @moduledoc """
  A very simple live view page that currently is just for mocking behavior

  Currently it receives a `:resource_uri` parameter.
  """
  use ExTeal.Web, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :foo, 1)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h1 class="text-blue-100 text-xl">Hello World</h1>
    <h2><%= @current_user.full_name %></h2>
    this is a live view
    <p><%= @foo %></p>
    <button phx-click="inc">Inc</button>
    """
  end

  @impl true
  def handle_event("inc", _params, socket) do
    {:noreply, assign(socket, :foo, socket.assigns.foo + 1)}
  end
end
