defmodule <%= manifest.module %> do
  @moduledoc """
  Configure ExTeal
  """
  use ExTeal.Manifest

  alias <%= manifest.ex_teal_context %>.{}

  def resources, do: []

  def plugins,
    do: []

  def dashboards, do: []

  def application_name, do: <%= inspect manifest.humanized_name %>
end
