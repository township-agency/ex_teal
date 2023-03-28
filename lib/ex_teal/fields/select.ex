defmodule ExTeal.Fields.Select do
  @moduledoc """
  The `Select` field may be used to generate a drop-down select menu.

  The select menu's options may be defined using the `Select.options/2` function:

      Select.make(:size)
      |> Select.options(["Small", "Medium"])
  """

  use ExTeal.Field
  alias ExTeal.Field

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
    %{
      field
      | options: Map.put_new(field.options, :field_options, Field.transform_options(options))
    }
  end

  @doc """
  At times it's convenient to be able to search or filter the list of options in a
  select field.  You can enable this by calling `Select.searchable` on the field:

      Select.make(:type) |> Select.options(~w(foo bar)) |> Select.searchable()

  When using this field, Teal will display an input field which allows you to filter
  the list based on it's key.
  """
  @spec searchable(Field.t()) :: Field.t()
  def searchable(field) do
    %{field | options: Map.put_new(field.options, :searchable, true)}
  end

  def with_options(field, options) when is_map(options) do
    IO.warn("with_options/2 is depreciated.  See `ExTeal.Fields.Select.options/2`")
    options(field, options)
  end

  def with_options(field, options_fn) when is_function(options_fn) do
    IO.warn("with_options/2 is depreciated.  See `ExTeal.Fields.Select.options/2`")
    option_value = options_fn.()
    options(field, option_value)
  end

  def display_using_labels(field) do
    IO.warn("display_using_labels/1 is depreciated.  See `ExTeal.Fields.Select.options/2`")
    field
  end

  @impl true
  def value_for(field, model, view) when view in [:show, :index] do
    value = ExTeal.Field.value_for(field, model, view)

    if field_represents_an_enum?(field, model) do
      value
    else
      option_values = all_options_for(field)
      option = Enum.find(option_values, &(&1.value == value)) || %{}
      Map.get(option, :key, nil)
    end
  end

  def value_for(field, model, view), do: Field.value_for(field, model, view)

  def all_options_for(field) do
    field.options
    |> Map.get(:field_options, [])
    |> Enum.map(fn
      %{group: _group, options: group_options} -> group_options
      option -> option
    end)
    |> List.flatten()
  end

  @impl true
  def filterable_as, do: ExTeal.FieldFilter.Select

  @impl true
  def apply_options_for(%Field{options: options} = field, model, _conn, _type) do
    if field_represents_an_enum?(field, model) and Map.fetch(options, :field_options) == :error do
      {:parameterized, Ecto.Enum, details} = schema_field_type(field, model)
      enum_options = Field.transform_options(details.values)
      %{field | options: Map.put(field.options, :field_options, enum_options)}
    else
      field
    end
  end

  defp field_represents_an_enum?(_field, model) when not is_struct(model), do: false

  defp field_represents_an_enum?(field, model) do
    case schema_field_type(field, model) do
      {:parameterized, Ecto.Enum, _} ->
        true

      _ ->
        false
    end
  end

  defp schema_field_type(field, model) do
    model.__struct__.__schema__(:type, field.field)
  end
end
