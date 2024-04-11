defmodule ExTeal.IndexPage do
  use ExTeal.Web, :live_view

  @impl true
  def mount(params, _session, socket) do
    IO.inspect(params)
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h1 class="text-red">Hello World</h1>
    <h2><%= @current_user.full_name %></h2> this is a live view
    """
  end
end
