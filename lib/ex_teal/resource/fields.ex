defmodule ExTeal.Resource.Fields do
  @moduledoc """
  Provides the `fields/0` callback used by the following ExTeal actions:

    * ExTeal.Resource.Index
  """

  alias ExTeal.{Field, Panel}

  @doc """
  Used to get the fields available to the current action.

  All resources will override this:

      def fields(_conn), do: [
        Id::make() |> sortable(),
        Text::make('Name') |> sortable(),
        DateTime::make(:updated_at, 'Last Updated At') |> hide_from_index()
      ]
  """
  @callback fields() :: list(module)

  @doc """
  Used to decorate the fields before
  """

  defmacro __using__(_) do
    quote do
      @behaviour ExTeal.Resource.Fields

      alias ExTeal.Resource.Fields

      def identifier(model), do: model.id

      @inferred_fields ExTeal.Resource.Fields.fields_from_model(__MODULE__)
      def fields, do: @inferred_fields

      def meta_for(method, data, all, total, resource, conn),
        do: Fields.meta_for(method, data, all, total, resource, conn)

      def serialize_response(method, resource, data, conn),
        do: Fields.serialize_response(method, resource, data, conn)

      defoverridable(fields: 0, serialize_response: 4, identifier: 1)
    end
  end

  def fields_from_model(_model) do
    []
  end

  def meta_for(:index, _data, all, total, resource, _conn) do
    %{
      label: resource.title(),
      fields: fields_for(:index, resource),
      total: total,
      all: all,
      sortable_by: resource.sortable_by() || false
    }
  end

  def serialize_response(:index, resource, data, _conn) do
    fields = fields_for(:index, resource)

    data
    |> Enum.map(fn x ->
      fields =
        fields
        |> apply_values(x, nil, :index)

      %{
        fields: apply_values(fields, x, nil, :index),
        id: x.id
      }
    end)
  end

  def serialize_response(:show, resource, model, _conn) do
    panels = Panel.gather_panels(resource)
    [default | _others] = panels

    fields =
      :show
      |> fields_for(resource)
      |> apply_values(model, default, :show)

    %{
      id: resource.identifier(model),
      fields: fields,
      panels: panels
    }
  end

  def fields_for(:index, resource) do
    resource
    |> all_fields()
    |> Enum.filter(& &1.show_on_index)
  end

  def fields_for(:show, resource) do
    resource
    |> all_fields()
    |> Enum.filter(& &1.show_on_detail)
  end

  def fields_for(:new, resource) do
    resource
    |> all_fields()
    |> Enum.filter(& &1.show_on_new)
  end

  def fields_for(:edit, resource) do
    resource
    |> all_fields()
    |> Enum.filter(& &1.show_on_edit)
  end

  def all_fields(resource) do
    resource.fields()
    |> Enum.map(&panel_fields/1)
    |> Enum.concat()
  end

  def field_for(resource, name) do
    result =
      resource
      |> all_fields()
      |> Enum.find(fn f -> f.field == String.to_existing_atom(name) end)

    case result do
      nil -> {:error, :not_found}
      result = %Field{} -> {:ok, result}
    end
  end

  defp panel_fields(%Field{} = field), do: [field]
  defp panel_fields(%Panel{fields: fields}), do: fields

  def apply_values(fields, model, panel \\ nil, type) do
    fields
    |> Enum.map(fn field ->
      value = field.type.value_for(field, model, type)

      field
      |> Map.put(:value, value)
      |> add_panel_key(panel)
      |> field.type.apply_options_for(model)
    end)
  end

  def add_panel_key(%Field{panel: panel} = field, _) when not is_nil(panel), do: field
  def add_panel_key(%Field{} = field, nil), do: field
  def add_panel_key(%Field{} = field, %Panel{key: key}), do: Map.put(field, :panel, key)
end
