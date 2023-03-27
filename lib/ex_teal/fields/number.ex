defmodule ExTeal.Fields.Number do
  @moduledoc false
  use ExTeal.Field

  def component, do: "text-field"

  def with_options(field, options) when is_map(options) do
    %{field | options: options}
  end

  @impl ExTeal.Field
  def value_for(field, model, type) do
    value = ExTeal.Field.value_for(field, model, type)

    cond do
      is_integer(value) ->
        Integer.to_string(value)

      is_float(value) ->
        Float.to_string(value)

      true ->
        value
    end
  end

  @impl ExTeal.Field
  def filterable_as, do: ExTeal.FieldFilter.Number
end
