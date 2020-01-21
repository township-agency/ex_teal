defmodule ExTeal.Fields.ManyToManyBelongsTo do
  @moduledoc """
  Internal Field that replicates a belongs to field for display during an
  index query of a many to many relationship.
  """

  use ExTeal.Field
  alias ExTeal.Field

  def component, do: "belongs-to"

  def make(relationship_name, related_resource, queried_resource) do
    field = Field.struct_from_field(__MODULE__, relationship_name, nil)

    %{
      field
      | private_options: %{queried_resource: queried_resource},
        relationship: related_resource
    }
  end

  def value_for(field, model, _type) do
    field.relationship.title_for_schema(model)
  end

  def apply_options_for(field, model, _type) do
    queried = field.private_options.queried_resource

    rel = queried.model().__schema__(:association, field.field)

    Map.put(field, :options, %{
      belongs_to_key: rel.owner_key,
      belongs_to_relationship: field.relationship.uri(),
      belongs_to_id: model.id
    })
  end
end
