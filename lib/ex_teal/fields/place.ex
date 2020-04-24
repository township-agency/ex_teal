defmodule ExTeal.Fields.Place do
  @moduledoc false
  use ExTeal.Field

  def component, do: "place-field"

  def filterable_as, do: ExTeal.FieldFilter.Text

  def value_for(field, model, view)
      when view in [:show, :index] do
    place = Map.get(model, field.field)
    "#{place.address} #{place.city} #{place.state} #{place.zip}"
  end

  def value_for(field, model, view), do: Field.value_for(field, model, view)
end
