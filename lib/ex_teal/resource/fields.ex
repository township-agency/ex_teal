defmodule ExTeal.Resource.Fields do
  @moduledoc """
  Provides the `fields/0` callback used by the following ExTeal actions:

    * ExTeal.Resource.Index
  """

  alias ExTeal.{Field, Panel}
  alias ExTeal.Fields.ManyToManyBelongsTo

  @doc """
  Used to get the fields available to the current action.

  All resources will override this:

      def fields(), do: [
        Id.make() |> sortable(),
        Text.make('Name') |> sortable(),
        DateTime.make(:updated_at, 'Last Updated At') |> hide_from_index()
      ]
  """
  @callback fields() :: list(Field.t())

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

  def meta_for(:index, _data, all, total, resource, conn) do
    fields = index_fields(resource, conn)

    %{
      label: resource.title(),
      fields: fields,
      total: total,
      all: all,
      sortable_by: resource.sortable_by() || false
    }
  end

  def serialize_response(:index, resource, data, conn) do
    fields = index_fields(resource, conn)
    policy = resource.policy()

    data
    |> Enum.map(fn model ->
      fields = apply_values(fields, model, resource, conn, :index, nil)

      %{
        fields: fields,
        id: id_for(model),
        meta: %{
          can_delete?: policy.delete?(conn, model),
          can_update?: policy.update?(conn, model),
          can_view?: policy.view?(conn, model),
          detail_link: resource.navigate_to(:detail, conn, model),
          edit_link: resource.navigate_to(:edit, conn, model)
        }
      }
    end)
  end

  def serialize_response(method, resource, model, conn) do
    panels = Panel.gather_panels(resource)
    [default | _others] = panels

    fields =
      :show
      |> fields_for(resource)
      |> apply_values(model, resource, conn, method, default)
      |> Enum.filter(&viewable/1)

    policy = resource.policy()

    %{
      id: resource.identifier(model),
      fields: fields,
      panels: panels,
      meta: %{
        can_delete?: policy.delete?(conn, model),
        can_update?: policy.update?(conn, model),
        can_view?: policy.view?(conn, model)
      }
    }
  end

  def index_fields(resource, conn) do
    is_many_to_many = Map.get(conn.params, "relationship_type") == "ManyToMany"
    is_has_many = Map.get(conn.params, "relationship_type") == "hasMany"

    fields =
      cond do
        is_many_to_many ->
          fields_for_many_to_many(resource, conn)

        is_has_many ->
          fields_for_has_many(resource, conn)

        true ->
          fields_for(:index, resource)
      end

    fields
    |> Enum.filter(&viewable/1)
    |> Enum.map(&apply_can_see(&1, conn))
    |> Enum.reject(&is_nil/1)
  end

  defp viewable(%{options: %{can_view_any: false}}), do: false
  defp viewable(%{}), do: true

  defp id_for(%{pivot: true, _row: %{id: id}}), do: id
  defp id_for(%{id: id}), do: id

  @doc """
  Instead of returning the fields for an index table of a resource,
  this function is called to render a simple belongs to field via a
  `ManyToManyBelongsTo` field.

  Given a many to many relationship between posts and tags, an index query
  for the tags associated with a post should return a single many to many belongs to
  field that represents a tag associated with the post.  The field will then have options
  built up to make it behave like a belongs_to on the client side.
  """
  def fields_for_many_to_many(_resource_queried, conn) do
    with {:ok, queried_through_resource_key} <- Map.fetch(conn.params, "via_resource"),
         {:ok, relationship} <- Map.fetch(conn.params, "via_relationship"),
         {:ok, queried_resource} <- ExTeal.resource_for(queried_through_resource_key),
         {:ok, related_resource} <-
           ExTeal.resource_for_relationship(queried_resource, relationship) do
      primary = [
        ManyToManyBelongsTo.make(
          String.to_existing_atom(relationship),
          related_resource,
          queried_resource
        )
      ]

      pivot =
        pivot_fields_for(
          queried_resource,
          String.to_existing_atom(relationship),
          related_resource
        )

      primary ++ pivot
    else
      _ -> {:error, :not_found}
    end
  end

  def fields_for_has_many(resource, conn) do
    with {:ok, queried_through_resource_key} <- Map.fetch(conn.params, "via_resource"),
         {:ok, relationship} <- Map.fetch(conn.params, "via_relationship"),
         {:ok, queried_resource} <- ExTeal.resource_for(queried_through_resource_key) do
      relationship_field =
        relationship_field(queried_resource, String.to_existing_atom(relationship))

      index_fields_for_many(relationship_field, resource)
    else
      _ -> {:error, :not_found}
    end
  end

  def pivot_fields_for(related, rel, _queried) do
    relationship_field = relationship_field(related, rel)

    with {:ok, options} <- Map.fetch(relationship_field, :private_options),
         {:ok, pivot_fields} <- Map.fetch(options, :pivot_fields) do
      pivot_fields
    else
      _ ->
        []
    end
  end

  def index_fields_for_many(relationship_field, queried_resource) do
    with {:ok, options} <- Map.fetch(relationship_field, :private_options),
         {:ok, index_fields} <- Map.fetch(options, :index_fields) do
      index_fields
    else
      _ ->
        fields_for(:index, queried_resource)
    end
  end

  @doc """
  Find the field on the resource that includes context for the relationship that
  is being queried.
  """
  def relationship_field(related_resource, rel) do
    related_resource
    |> all_fields()
    |> Enum.find(&(&1.field == rel))
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
    |> Enum.map(&subfields/1)
    |> Enum.concat()
  end

  def field_for(resource, name) do
    field_name = String.to_existing_atom(name)

    result =
      resource
      |> all_fields()
      |> Enum.find(fn f -> f.field == field_name end)

    case result do
      nil -> {:error, :not_found}
      result = %Field{} -> {:ok, result}
    end
  end

  defp subfields(%Field{options: %{fields: fields}}), do: fields
  defp subfields(%Field{} = field), do: [field]
  defp subfields(%Panel{fields: fields}), do: fields

  def apply_values(fields, model, resource, conn, type, panel \\ nil)

  def apply_values(fields, %{pivot: true} = model, resource, conn, type, panel) do
    model = Map.merge(model._row, model._pivot)
    apply_values(fields, model, resource, conn, type, panel)
  end

  def apply_values(fields, model, _resource, conn, type, panel) do
    fields
    |> Enum.map(fn field ->
      value = field.type.value_for(field, model, type)

      field
      |> Map.put(:value, value)
      |> add_panel_key(panel)
      |> field.type.apply_options_for(model, conn, type)
      |> apply_can_see(conn)
    end)
    |> Enum.reject(&is_nil/1)
  end

  @doc """
  Apply the can_see function attached to a field to filter
  out the field from serialized responses.
  """
  @spec apply_can_see(Field.t(), Plug.Conn.t()) :: Field.t() | nil
  def apply_can_see(%Field{can_see: nil} = field, _), do: field

  def apply_can_see(%Field{can_see: see} = field, conn) when is_function(see, 1) do
    if see.(conn) do
      field
    else
      nil
    end
  end

  def add_panel_key(%Field{panel: panel} = field, _) when not is_nil(panel), do: field
  def add_panel_key(%Field{} = field, nil), do: field
  def add_panel_key(%Field{} = field, %Panel{key: key}), do: Map.put(field, :panel, key)
end
