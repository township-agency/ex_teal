defmodule ExTeal.Fields.Text do
  @moduledoc false
  use ExTeal.Field

  def component, do: "text-field"

  def filterable_as, do: ExTeal.FieldFilter.Text
end
