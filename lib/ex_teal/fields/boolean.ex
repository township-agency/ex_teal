defmodule ExTeal.Fields.Boolean do
  @moduledoc false
  use ExTeal.Field
  alias ExTeal.Field

  def component, do: "boolean"

  def make(name, label \\ nil) do
    field = Field.struct_from_field(__MODULE__, name, label)
    Map.put(field, :text_align, "center")
  end
end
