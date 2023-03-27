defmodule ExTeal.Fields.Hidden do
  @moduledoc """
  A hidden field is a field that is not shown on the index or detail pages, but is still
  rendered on forms for use with embedded fields that have ids.
  """
  use ExTeal.Field

  def component, do: "hidden-field"

  @impl true
  def filterable_as, do: nil

  def show_on_index, do: false

  def show_on_detail, do: false
end
