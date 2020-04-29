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
            getter: nil,
            show_on_index: true,
            show_on_detail: true,
            show_on_new: true,
            show_on_edit: true,
            as_html: false,
            sanitize: :strip_tags,
            relationship: nil

  alias ExTeal.Naming

  @callback make(atom(), String.t() | nil) :: Field.t()

  @callback value_for(Field.t(), struct(), atom()) :: any()

  @callback apply_options_for(Field.t(), struct(), atom()) :: Field.t()

  @callback filterable_as :: ExTeal.FieldFilter.valid_type()

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

      def apply_options_for(field, _model, _type), do: field

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
        apply_options_for: 3
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

  def value_for(field, model, _type) do
    Map.get(model, field.field)
  end

  @doc """
  Use a getter function to display a computed field on the resource.

  The getter function is given a schema and expects a string result
  """
  def get(field, func) do
    field
    |> Map.put(:getter, func)
    |> Map.put(:sortable, false)
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

  def help_text(%Field{options: options} = f, text),
    do: %{f | options: Map.put_new(options, :help_text, text)}
end
