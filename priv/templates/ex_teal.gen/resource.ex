defmodule <%= resource.web_module_alias %> do
  @moduledoc """
    ExTeal Resource
  """
  use ExTeal.Resource
  alias <%= resource.module_alias %>
  alias ExTeal.Fields.{<%= resource.fields %>}
<%= if resource.assocs_by_context do %>
<%= for {k, v} <- resource.assocs_by_context do %>
  alias <%=resource.base%>.<%=k%>.{<%=v |> Enum.sort() |> Enum.join(", ")%>}
<% end %>
<% end %>

  @impl true
  def model, do: <%= resource.model %>

  @impl true
  def with, do: []

  @impl true
  def title, do: "<%= resource.title %>"

  @impl true
  def actions(_), do: []

  @impl true
  def search, do: [<%= for k <- resource.search_fields do %><%= inspect k %>, <% end %>]

  @impl true
  def fields, do: [
  <%= for {k, v} <- resource.types do %> <%= v |> to_string() |> String.split(".") |> List.last %>.make(<%= inspect k %>),
  <% end %><%= for {k, camel_key, type, _context} <- resource.assocs do %> <%= type %>.make(<%= inspect k %>, <%= camel_key %>),
  <% end %>]

end

