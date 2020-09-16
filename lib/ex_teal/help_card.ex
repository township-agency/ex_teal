defmodule ExTeal.HelpCard do
  @moduledoc """
  Card that sits on the main, default dashboard
  """

  use ExTeal.Card

  @impl true
  def width, do: "full"

  @impl true
  def component, do: "help-card"
end
