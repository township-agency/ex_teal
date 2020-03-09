defmodule ExTeal.Fields.BelongsTo do
  @moduledoc """
  The `BelongsTo` field corresponds to a `belongs_to` ecto relationship.  For example,
  let's assume a `Post` schema `belongs_to` a `User` schema.  We may add the relationship
  to our `Post` ExTeal resource like so:

      alias ExTeal.Fields.BelongsTo

      BelongsTo.make(:user)

  # Title Attributes

  When a `BelongsTo` field is shown on a resource creation/update screen, a drop-down
  selection menu or search menu will display the "title" of the resource.  For example, a
  `User` resource may display the `name` attribute as it's title.  Then, when the resource
  is shown in a `BelongsTo` selection menu, that attribute will be displayed.  You can override
  the title displayed by overriding the display_title/1 function:

      def display_title(schema) do
        String.capitalize(schema.name)
      end
  """

  use ExTeal.Field
  alias ExTeal.Field

  def component, do: "belongs-to"

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
            belongs_to_id: id
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
    opts = Map.merge(field.options, %{searchable: true})
    Map.put(field, :options, opts)
  end
end
