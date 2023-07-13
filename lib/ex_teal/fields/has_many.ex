defmodule ExTeal.Fields.HasMany do
  @moduledoc """
  The `HasMany` field corresponds to a `has_many` ecto relationship.  For example,
  let's assume a `User` schema has many `Post` schema.  We may add the relationship
  to our `User` ExTeal resource like so:

      alias ExTeal.Fields.HasMany

      HasMany.make(:posts)
  """

  use ExTeal.Field
  alias ExTeal.Resource

  def component, do: "has-many"

  def value_for(_field, _model, _type), do: nil

  def show_on_index, do: false
  def show_on_new, do: false
  def show_on_edit, do: false

  def apply_options_for(field, model, conn, _type) do
    relationship = model.__struct__.__schema__(:association, field.field)

    with {:ok, rel, resource} <- rel_and_resource(relationship, model) do
      opts =
        Map.merge(field.options, %{
          has_many_relationship: field.field,
          listable: true
        })

      %{
        field
        | options: Map.merge(Resource.to_json(resource, conn), opts),
          private_options: Map.merge(field.private_options, %{rel: rel})
      }
    end
  end

  defp rel_and_resource(%Ecto.Association.HasThrough{through: through_keys} = rel, model) do
    queried_model =
      Enum.reduce(through_keys, model.__struct__, fn key, m ->
        rel = m.__schema__(:association, key)
        rel.queryable
      end)

    {:ok, resource} = ExTeal.resource_for_model(queried_model)
    {:ok, rel, resource}
  end

  defp rel_and_resource(%Ecto.Association.Has{queryable: model} = rel, _model) do
    {:ok, resource} = ExTeal.resource_for_model(model)
    {:ok, rel, resource}
  end

  @doc """
  Define a list of custom index fields to use when displaying the has many
  relationship.

      HasMany.make(:posts)
      |> HasMany.with_index_fields([
        Text.make(:title)
      ])

  This list of fields will override the fields used when displaying, sorting,
  and filtering the related table.
  """
  @spec with_index_fields(Field.t(), [Field.t()]) :: Field.t()
  def with_index_fields(has_many_field, index_fields) do
    %{
      has_many_field
      | private_options: Map.merge(has_many_field.private_options, %{index_fields: index_fields})
    }
  end
end
