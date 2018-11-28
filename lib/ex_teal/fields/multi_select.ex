defmodule ExTeal.Fields.MultiSelect do
  @moduledoc """
  The `MultiSelect` field may be used to generate a drop-down menu with multiple fields.

  The select menu's options may be defined using the `MultiSelect/with_options/2` function:

      MultiSelect.make(:regions)
      |> MultiSelect.with_options([%{value: 1, label: "USA"}, %{value: 2, label: "EU"}])

  """

  use ExTeal.Field

  def component, do: "multi-select"

  def default_sortable, do: false

  def with_options(field, options) when is_list(options) do
    %{field | options: options, private_options: %{display_using_labels: false}}
  end

  def with_options(field, options_fn) when is_function(options_fn) do
    options = options_fn.()
    with_options(field, options)
  end

  def get(field, getter) when is_function(getter) do
    pvt_opts = Map.merge(field.private_options, %{getter: getter})
    %{field | private_options: pvt_opts}
  end

  def value_for(%Field{private_options: %{getter: getter}} = _field, model, _view)
      when is_function(getter) do
    getter.(model)
  end

  def value_for(field, model, view), do: Field.value_for(field, model, view)
end
