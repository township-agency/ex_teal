defmodule ExTeal.WelcomeDashboard do
  @moduledoc """
  The default dashboard that contains links to documentation
  for new engineers.
  """
  use ExTeal.Dashboard

  def title, do: "Main"

  def uri, do: "main"

  def cards(_conn), do: [ExTeal.HelpCard]
end
