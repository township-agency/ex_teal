defmodule ExTeal.Fields.Select do
  @moduledoc """
  The `Select` field may be used to generate a drop-down select menu.

  The select menu's options may be defined using the `Select.options/2` function:

      Select.make(:size)
      |> Select.options(["Small", "Medium"])
  """

  use ExTeal.Field

  def component, do: "select"

  @doc """
  Define the options for the select field.  The function accepts a list of
  options that are either strings or maps with of `value` and `label` keys.  If
  the list members are strings, the value will be used for both the value and label
  of the `<option>` element it represents.

  `options` are expected to be an enumerable which will be used to generate
  each respective `option`.  The enumerable may have:

    * keyword lists - each keyword list is expected to have the keys `:key` and
      `:value`.  Additional keys such as `:disabled` may be given to customize
      the option

    * two-item tuples - where the first element is an atom, string or integer to
      be used as the option label and the second element is an atom, string or
      integer to be used as the option value

    * atom, string or integer - which will be used as both label and value for
      the generated select

  ## Optgroups

  If `options` is a map or keyword list where the firs element is a string, atom,
  or integer and the second element is a list or a map, it is assumed the key
  will be wrapped in an `<optgroup>` and teh value will be used to generate
  `<options>` nested under the group.

  This functionality is equivalent to `Phoenix.HTML.Form.select/3`
  """
  def options(field, options) do
    %{field | options: %{options | field_options: transform_options(options)}}
  end

  @doc """
  Returns the options to be used inside of a select.
  """
  def transform_options(options) do
    Enum.into(options, [], fn
      {option_key, option_value} ->
        option(option_key, option_value, [])

      options_list when is_list(options_list) ->
        {option_key, options_list} = Keyword.pop(options_list, :key)

        option_key ||
          raise ArgumentError,
                "expected :key key when building <option> from keyword list: #{
                  inspect(options_list)
                }"

        {option_value, options_list} = Keyword.pop(options_list, :value)

        option_value ||
          raise ArgumentError,
                "expected :value key when building option from keyword list: #{
                  inspect(options_list)
                }"

        option(option_key, option_value, options_list)

      option_value ->
        option(option_value, option_value, [])
    end)
  end

  defp option(group_label, group_values, [])
       when is_list(group_values) or is_map(group_values) do
    %{group: group_label, options: transform_options(group_values)}
  end

  defp option(key, value, extra) do
    %{value: value, key: key, disabled: Keyword.get(extra, :disabled, false)}
  end

  @depreciated "Use `Select.options/2` instead"
  def with_options(field, options) when is_map(options) do
    options(field, options)
  end

  def with_options(field, options_fn) when is_function(options_fn) do
    option_value = options_fn.()
    options(field, options)
  end

  @depreciated "Use `Select.options/2` instead"
  def display_using_labels(field) do
    field
  end

  @impl true
  def value_for(%Field{private_options: %{display_using_labels: true}} = field, model, view)
      when view in [:show, :index] do
    Map.get(field.options, Map.get(model, field.field))
  end

  def value_for(field, model, view), do: Field.value_for(field, model, view)

  @impl true
  def filterable_as, do: ExTeal.FieldFilter.Select
end
