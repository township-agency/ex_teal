defmodule ExTeal.Fields.BelongsTo do
  @moduledoc """
  The `BelongsTo` field corresponds to a `belongs_to` ecto relationship.  For example,
  let's assume a `Post` schema `belongs_to` a `User` schema.  We may add the relationship
  to our `Post` ExTeal resource like so:

      alias ExTeal.Fields.BelongsTo

      BelongsTo.make(:user)
  """

  use ExTeal.Field
  alias ExTeal.Field

  def component, do: "belongs-to"

  @impl true
  def filterable_as, do: ExTeal.FieldFilter.BelongsTo

  @impl true
  def make(relationship_name, module, label \\ nil) do
    __MODULE__
    |> Field.struct_from_field(relationship_name, label)
    |> Map.put(:relationship, module)
  end

  @impl true
  def value_for(field, model, _type) do
    schema = Map.get(model, field.field)

    with true <- not is_nil(schema),
         {:ok, resource} <- ExTeal.resource_for_model(field.relationship) do
      resource.title_for_schema(schema)
    else
      _ ->
        nil
    end
  end

  @impl true
  def apply_options_for(field, model, conn, _type) do
    id =
      case Map.get(model, field.field) do
        nil -> nil
        module -> Map.get(module, :id)
      end

    case ExTeal.resource_for_model(field.relationship) do
      {:ok, resource} ->
        rel = model.__struct__.__schema__(:association, field.field)

        opts =
          Map.merge(field.options, %{
            belongs_to_key: rel.owner_key,
            belongs_to_relationship: resource.uri(),
            belongs_to_id: id,
            reverse: reverse_relationship?(resource, rel, conn)
          })

        Map.put(field, :options, opts)

      {:error, _} ->
        field
    end
  end

  @doc """
  Mark a Belongs To Field as searchable, allowing the UX to
  search the related resource for matches in the create and update forms
  """
  @spec searchable(Field.t()) :: Field.t()
  def searchable(field) do
    IO.warn("searchable/1 is deprecated.  BelongsTo fields are always searchable")
    field
  end

  defp reverse_relationship?(resource, rel, conn) do
    via_resource = Map.get(conn.params, "viaResource")
    via_relationship = Map.get(conn.params, "viaRelationship")

    if is_nil(via_resource) || via_resource != resource.uri() do
      false
    else
      matches_relationship?(rel, via_relationship)
    end
  end

  defp matches_relationship?(rel, via_relationship) do
    all_relationships = rel.related.__schema__(:associations)

    if Enum.any?(all_relationships, fn assoc -> Atom.to_string(assoc) == via_relationship end) do
      known_relationship =
        rel.related.__schema__(:association, String.to_existing_atom(via_relationship))

      rel.owner_key == known_relationship.related_key
    else
      false
    end
  end
end
