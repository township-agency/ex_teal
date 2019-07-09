defmodule ExTeal.Fields.ManyToMany do
  @moduledoc """
  The `ManyToMany` field corresponds to a `many_to_many` ecto relationship.  For example,
    let's assume a `User` schema has a `many_to_many` relationship with a `Role` schema.
  We can add the relationship to our `User` resource like so:

      alias ExTeal.Fields.ManyToMany

      ManyToMany.make(:roles)
  """

  use ExTeal.Field
  alias ExTeal.Field
  alias ExTeal.Resource

  def make(relationship_name, module, label \\ nil) do
    __MODULE__
    |> Field.struct_from_field(relationship_name, label)
    |> Map.put(:relationship, module)
  end

  def component, do: "many-to-many"

  def value_for(_field, _model, _type), do: nil

  def show_on_index, do: false
  def show_on_new, do: false
  def show_on_edit, do: false

  def apply_options_for(field, model) do
    rel = model.__struct__.__schema__(:association, field.field)

    with {:ok, resource} <- ExTeal.resource_for_model(rel.queryable) do
      opts =
        Map.merge(field.options, %{
          many_to_many_relationship: field.field,
          listable: true
        })

      %{
        field
        | options: Map.merge(Resource.to_json(resource), opts),
          private_options: %{rel: rel}
      }
    end
  end

  def with_pivot_fields(field, pivot_fields) do
    pivot_fields = Enum.map(pivot_fields, &Map.put(&1, :pivot_field, true))
    %{field | private_options: %{pivot_fields: pivot_fields}}
  end
end
