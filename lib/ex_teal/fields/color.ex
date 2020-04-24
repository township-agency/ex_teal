defmodule ExTeal.Fields.Color do
  @moduledoc false
  use ExTeal.Field

  def component, do: "color"

  def filterable_as, do: ExTeal.FieldFilter.Text
end
