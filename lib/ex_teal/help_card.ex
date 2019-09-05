defmodule ExTeal.HelpCard do
  @moduledoc """
  Card that sits on the main, default dashboard
  """

  use ExTeal.Card

  def width, do: "full"

  def component, do: "help-card"
end
