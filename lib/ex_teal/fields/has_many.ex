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
    rel = model.__struct__.__schema__(:association, field.field)

    with {:ok, resource} <- ExTeal.resource_for_model(rel.queryable) do
      opts =
        Map.merge(field.options, %{
          has_many_relationship: field.field,
          listable: true
        })

      Map.put(field, :options, Map.merge(Resource.to_json(resource, conn), opts))
    end
  end
end
