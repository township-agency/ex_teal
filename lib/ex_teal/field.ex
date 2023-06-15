defmodule ExTeal.Field do
  @moduledoc """
  The core struct that represents a field on a resource served by ExTeal.
  """

  @serialized ~w(as_html attribute component name options prefix_component sortable text_align value panel)a
  @derive {Jason.Encoder, only: @serialized}

  @type t :: %__MODULE__{}

  alias __MODULE__

  defstruct field: nil,
            attribute: nil,
            component: nil,
            type: nil,
            name: nil,
            options: %{},
            private_options: %{},
            prefix_component: nil,
            sortable: true,
            filterable: false,
            pivot_field: false,
            text_align: "left",
            value: nil,
            panel: nil,
            embed_field: nil,
            getter: nil,
            can_see: nil,
            show_on_index: true,
            show_on_detail: true,
            show_on_new: true,
            show_on_edit: true,
            as_html: false,
            sanitize: :strip_tags,
            relationship: nil,
            virtual: false

  alias ExTeal.Naming

  @callback make(atom(), String.t() | nil) :: Field.t()

  @callback value_for(Field.t(), struct(), atom()) :: any()

  @callback apply_options_for(Field.t(), struct(), struct(), atom()) :: Field.t()

  @callback filterable_as :: ExTeal.FieldFilter.valid_type()

  @callback default_sortable :: boolean()

  @callback sanitize_as :: atom() | false

  defmacro __using__(_opts) do
    quote do
      @behaviour ExTeal.Field
      alias ExTeal.Field

      def make(name, label \\ nil), do: Field.struct_from_field(__MODULE__, name, label)

      def options, do: %{}
      def prefix_component, do: true
      def default_sortable, do: true
      def show_on_index, do: true
      def show_on_detail, do: true
      def show_on_new, do: true
      def show_on_edit, do: true
      def sanitize_as, do: :strip_tags
      def as_html, do: false

      def filterable_as, do: false

      def field_name(name, label) do
        Field.field_name(name, label)
      end

      def value_for(field, model, method), do: Field.value_for(field, model, method)

      def apply_options_for(field, _model, _conn, _type), do: field

      defoverridable(
        options: 0,
        prefix_component: 0,
        default_sortable: 0,
        field_name: 2,
        show_on_index: 0,
        show_on_detail: 0,
        show_on_new: 0,
        show_on_edit: 0,
        sanitize_as: 0,
        as_html: 0,
        filterable_as: 0,
        make: 2,
        make: 1,
        value_for: 3,
        apply_options_for: 4
      )
    end
  end

  def struct_from_field(implementation, name, label) do
    %__MODULE__{
      field: name,
      type: implementation,
      attribute: Atom.to_string(name),
      component: implementation.component(),
      name: implementation.field_name(name, label),
      options: implementation.options(),
      prefix_component: implementation.prefix_component(),
      sortable: implementation.default_sortable(),
      show_on_index: implementation.show_on_index(),
      show_on_detail: implementation.show_on_detail(),
      show_on_new: implementation.show_on_new(),
      show_on_edit: implementation.show_on_edit(),
      sanitize: implementation.sanitize_as(),
      as_html: implementation.as_html(),
      filterable: implementation.filterable_as()
    }
  end

  def field_name(name, nil) do
    Naming.humanize(name)
  end

  def field_name(_, label), do: label

  def value_for(%Field{getter: getter}, model, _type) when is_function(getter) do
    getter.(model)
  end

  def value_for(%Field{field: f, attribute: attr} = field, model, _type) do
    if f == attr || Atom.to_string(f) == attr do
      Map.get(model, f)
    else
      nested_value_for(field, model)
    end
  end

  def nested_value_for(%Field{attribute: attr}, model) do
    attr
    |> Atom.to_string()
    |> String.split(".")
    |> Enum.map(&String.to_existing_atom/1)
    |> Enum.reduce(model, fn attr, m ->
      if is_nil(m), do: nil, else: Map.get(m, attr)
    end)
  end

  @doc """
  Use a getter function to display a computed field on the resource.

  The getter function is given a schema and expects a string result
  """
  def get(field, func) do
    field
    |> Map.put(:getter, func)
    |> Map.put(:sortable, false)
    |> Map.put(:filterable, false)
    |> Map.put(:show_on_new, false)
    |> Map.put(:show_on_edit, false)
  end

  @doc """
  Override the default filter for the field.
  """
  @spec filter_as(Field.t(), module) :: Field.t()
  def filter_as(field, filter_module) do
    Map.put(field, :filterable, filter_module)
  end

  @doc """
  Mark a field as virtual, which will update how teal queries the database for the field.

  This is relevant for fields that are based on schemaless queries in resources that represent complex
  queries in read-only situations.  For example, if a resource has a records definition like:

      from(p in "posts", select: %{user_id: p.user_id, count: count(p.id)}, group_by: p.user_id)

  Sorting by that resource would fail without marking the `Number.make(:count)` field as
  virtual.  Virtual fields allow Teal to sort by computed fields that are not backed
  by a direct database reference, assuming the field is named with `Ecto.Query.API.selected_as/2`:

      from(
        p in "posts",
        select: %{user_id: p.user_id, count: p.id |> count() |> selected_as(:count)},
        group_by: p.user_id
      )

  A resource can then use `Number.make(:count) |> Field.virtual()` to mark the field as virtual.
  """
  @spec virtual(Field.t()) :: Field.t()
  def virtual(field) do
    %{field | virtual: true, filterable: false, show_on_new: false, show_on_edit: false}
  end

  def help_text(%Field{options: options} = f, text),
    do: %{f | options: Map.put_new(options, :help_text, text)}

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
  `<options>` nested under the group.  This functionality is only handled in the UI for
  select fields, boolean groups will not respond.

  This functionality is equivalent to `Phoenix.HTML.Form.select/3`
  """
  def transform_options(options) do
    Enum.into(options, [], fn
      {option_key, option_value} ->
        option(option_key, option_value, [])

      options_list when is_list(options_list) ->
        {option_key, options_list} = Keyword.pop(options_list, :key)

        option_key ||
          raise ArgumentError,
                "expected :key key when building <option> from keyword list: #{inspect(options_list)}"

        {option_value, options_list} = Keyword.pop(options_list, :value)

        option_value ||
          raise ArgumentError,
                "expected :value key when building option from keyword list: #{inspect(options_list)}"

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
end
