defmodule ExTeal.Fields.HasOne do
  @moduledoc """
  The `HasOne` field corresponds to a `has_one` ecto relationship.  For example,
  let's assume a `Post` schema `has_one` `PermaLink` schema.  We may add the relationship
  to our `Post` ExTeal resource like so:

      alias ExTeal.Fields.HasOne

      HasOne.make(:permalink)

  # Title Attributes

  When a `HasOne` field is shown on an associated `BelongsTo` resources index/detail screen, the associated
  row will have a link to the `HasOne` and will display the "title" of the resource.  For example, a
  `permalink` resource may display the `address` attribute as it's title.  Then, when the resource
  is shown as an association on the belongs_to index or detail views, that attribute will be displayed, supported attributes are `name`, `title`, or `address`.
  """

  use ExTeal.Field
  alias ExTeal.{Field, Resource}

  def component, do: "has-one"

  def show_on_new, do: false
  def show_on_edit, do: false

  @impl true
  def make(relationship_name, module, label \\ nil) do
    __MODULE__
    |> Field.struct_from_field(relationship_name, label)
    |> Map.put(:relationship, module)
  end

  @impl true
  def value_for(field, model, _type) do
    schema = Map.get(model, field.field)

    case ExTeal.resource_for_model(field.relationship) do
      {:ok, resource} ->
        resource.title_for_schema(schema)

      {:error, :not_found} ->
        nil
    end
  end

  @impl true
  def apply_options_for(field, model, _type) do
    rel = model.__struct__.__schema__(:association, field.field)

    with {:ok, resource} <- ExTeal.resource_for_model(rel.queryable) do
      opts =
        Map.merge(field.options, %{
          has_one_relationship: field.field,
          listable: true
        })

      Map.put(field, :options, Map.merge(Resource.to_json(resource), opts))
    end
  end
end
