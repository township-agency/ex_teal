defmodule ExTeal.Fields.ID do
  @moduledoc false

  use ExTeal.Field
  alias ExTeal.Field

  def component, do: "text-field"

  def filterable_as, do: ExTeal.FieldFilter.Number

  def make(name, label \\ nil) do
    field = Field.struct_from_field(__MODULE__, name, label)
    Map.merge(field, %{show_on_new: false, show_on_edit: false})
  end
end
