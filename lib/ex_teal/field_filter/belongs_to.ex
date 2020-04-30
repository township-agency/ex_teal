defmodule ExTeal.FieldFilter.BelongsTo do
  @moduledoc """
  Field Filter for belongs to fields

  """
  use ExTeal.FieldFilter
  import Ecto.Query
  alias ExTeal.FieldFilter

  @impl true
  def operators(_),
    do: [
      %{"op" => "="},
      %{"op" => "!="},
      %{"op" => "is empty", "no_operand" => true},
      %{"op" => "not empty", "no_operand" => true}
    ]

  @impl true
  def interface_type, do: "belongs-to"

  @impl true
  def filter(query, %{"operator" => "=", "operand" => val}, field_name, resource)
      when val != "" and not is_nil(val) do
    belongs_to_key = key_for(resource, field_name)
    where(query, [q], field(q, ^belongs_to_key) == ^val)
  end

  def filter(query, %{"operator" => "!=", "operand" => val}, field_name, resource)
      when val != "" and not is_nil(val) do
    belongs_to_key = key_for(resource, field_name)
    where(query, [q], field(q, ^belongs_to_key) != ^val)
  end

  def filter(query, %{"operator" => "is empty"}, field_name, resource) do
    belongs_to_key = key_for(resource, field_name)
    where(query, [q], is_nil(field(q, ^belongs_to_key)))
  end

  def filter(query, %{"operator" => "not empty"}, field_name, resource) do
    belongs_to_key = key_for(resource, field_name)
    where(query, [q], not is_nil(field(q, ^belongs_to_key)))
  end

  def filter(query, _, _, _), do: query

  @impl true
  def serialize(field, resource) do
    defaults = FieldFilter.default_serialization(field, interface_type(), operators(field))

    case ExTeal.resource_for_model(field.relationship) do
      {:ok, related_resource} ->
        model = struct(resource.model(), %{})
        rel = model.__struct__.__schema__(:association, field.field)

        Map.merge(defaults, %{
          belongs_to_key: rel.owner_key,
          belongs_to_relationship: related_resource.uri(),
          searchable: Map.get(field.options, :searchable, false)
        })

      _ ->
        defaults
    end
  end

  defp key_for(resource, field_name) do
    model = struct(resource.model(), %{})
    rel = model.__struct__.__schema__(:association, field_name)
    rel.owner_key
  end
end
