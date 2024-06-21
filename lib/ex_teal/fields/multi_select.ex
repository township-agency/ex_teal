defmodule ExTeal.Fields.MultiSelect do
  @moduledoc """
  The `MultiSelect` field may be used to generate a drop-down menu with multiple fields.

  The select menu's options may be defined using the `MultiSelect/with_options/2` function:

      MultiSelect.make(:regions)
      |> MultiSelect.with_options([%{value: 1, label: "USA"}, %{value: 2, label: "EU"}])

  You can also return a list of maps with `value`, `title`, `subtitle` and `thumbnail` keys
  to use 'card' style taggables, useful when the multiselect represents a relationship.
  """

  @type simple_option :: %{
          value: :integer | String.t(),
          label: String.t()
        }

  @type card_option :: %{
          required(:value) => :integer | String.t(),
          required(:title) => String.t(),
          optional(:subtitle) => String.t(),
          optional(:thumbnail) => String.t()
        }

  @type valid_option :: simple_option | card_option

  @type valid_options :: list(valid_option)

  use ExTeal.Field
  alias ExTeal.Field

  def component, do: "multi-select"

  def default_sortable, do: false

  @spec with_options(Field.t(), valid_options | (-> valid_options)) :: Field.t()
  def with_options(field, options) when is_list(options) do
    %{field | options: options}
  end

  def with_options(field, options_fn) when is_function(options_fn) do
    IO.warn(
      "with_options/2 callback is depreciated, and will be removed in 1.0.  See `ExTeal.Fields.MultiSelect.with_options/2`"
    )

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
