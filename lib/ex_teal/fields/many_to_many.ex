defmodule ExTeal.Fields.ManyToMany do
  @moduledoc """
  The `ManyToMany` field corresponds to a `many_to_many` ecto relationship.  For example,
  let's assume a `User` schema has a `many_to_many` relationship with a `Role` schema.
  We can add the relationship to our `User` resource like so:

      alias ExTeal.Fields.ManyToMany

      ManyToMany.make(:roles)

  ## Customizing Index Tables

  Let's assume we have a `User` schema with a `many_to_many` relationship with a `Role` schema.  The pivot
  schema has a :primary boolean field.  We want to display the `Role`'s name and the `User`'s email and
  the primary boolean field on the index table of 'Roles' for a 'User'. We can do this by defining:

      ManyToMany.make(:roles, Role)
      |> ManyToMany.with_pivot_fields([ExTeal.Fields.Boolean.make(:primary)])

  The relationship table, attach and edit-attached interfaces now all a user to manage the 'primary' field
  which only exists on the pivot table.

  ## Customizing Index Tables

  By default, the ManyToMany field produces a `ManyToManyBelongsTo` field on the index table.  This field
  appears as a BelongsTo field, providing the title for the linked resource and a link to the detail page
  of the linked asset, in the previous example 'Role'.  There are times where you might need to customize
  the index table, overriding the `ManyToManyBelongsTo` and providing a unique list of fields to display.

  Enter `with_index_fields/2` and `with_index_query/2`.  By default, Teal queries for both the related resource
  and the join to the current resource via some of the meta data associated with the underlying `Ecto.Assoc`
  struct.  The results are then loaded in a custom resource lookup select query.  When extending the default
  many-to-many functionality, the query must return a `ExTeal.Resource.pivot_resource()` type.

  ### Example

  Assume a `User` has many to many with `Org` through a `Membership` schema.  `Membership` has a role field and we want to display some
  extra information in the `Org` many-to-many table for a user.  We could define that as:

      ManyToMany.make(:orgs, Org)
      |> ManyToMany.with_index_fields([
        ExTeal.Fields.Text.make(:name)
        ExTeal.Fields.Boolean.make(:active),
        ExTeal.Fields.Select.make(:org_type),
        ExTeal.Fields.Number.make(:member_count) |> ExTeal.Field.virtual()
      ])
      |> ManyToMany.with_index_query(fn query, _assoc, _resource_id ->
        query
        |> Ecto.Query.join(:left, [o], m in assoc(o, :memberships))
        |> Ecto.Query.select(query, [o, x, m], %{
          _row: %{
            name: o.name,
            active: o.active,
            org_type: o.org_type,
            member_count: selected_as(count(m.id), :member_count)
          },
          _pivot: x,
          pivot: true
        })
        |> Ecto.Query.group_by([o, x], [o.id, x.org_id])
      end)
      |> ManyToMany.with_pivot_fields([ExTeal.Fields.Select.make(:role)])

  What a query, what a pipe. There are some conditions here.  This functionality is only available when
  a `many_to_many` assocation is defined with a join_through schema.  If the many to many is joined
  only through the table name, you may be able to customize the index fields by defining a `with_index_fields/2`
  and ignoring the `with_index_query/2` function.  If you need to customize the query, you can do so by
  simply returning a full schema and avoiding the `ExTeal.Resource.pivot_resource()` type.
  """

  use ExTeal.Field
  alias ExTeal.Field
  alias ExTeal.Fields.ManyToManyBelongsTo
  alias ExTeal.Resource

  def make(relationship_name, module, label \\ nil) do
    field = Field.struct_from_field(__MODULE__, relationship_name, label)
    %{field | options: Map.merge(field.options, %{has_pivot_fields: false}), relationship: module}
  end

  def component, do: "many-to-many"

  def value_for(_field, _model, _type), do: nil

  def show_on_index, do: false
  def show_on_new, do: false
  def show_on_edit, do: false

  def apply_options_for(field, model, conn, _type) do
    rel = model.__struct__.__schema__(:association, field.field)

    with {:ok, resource} <- ExTeal.resource_for_model(rel.queryable) do
      opts =
        Map.merge(field.options, %{
          many_to_many_relationship: field.field,
          listable: true
        })

      %{
        field
        | options: Map.merge(Resource.to_json(resource, conn), opts),
          private_options: Map.merge(field.private_options, %{rel: rel})
      }
    end
  end

  def with_pivot_fields(field, pivot_fields) do
    pivot_fields = Enum.map(pivot_fields, &Map.put(&1, :pivot_field, true))

    %{
      field
      | private_options: Map.merge(field.private_options, %{pivot_fields: pivot_fields}),
        options: Map.merge(field.options, %{has_pivot_fields: true})
    }
  end

  @spec with_index_fields(Field.t(), [Field.t()]) :: Field.t()
  def with_index_fields(many_to_many_field, index_fields) do
    %{
      many_to_many_field
      | private_options:
          Map.merge(many_to_many_field.private_options, %{index_fields: index_fields})
    }
  end

  @spec with_index_query(Field.t(), (Ecto.Query.t(), struct(), any() -> Ecto.Query.t())) ::
          Field.t()
  def with_index_query(many_to_many_field, index_query_fn) do
    %{
      many_to_many_field
      | private_options:
          Map.merge(many_to_many_field.private_options, %{index_query_fn: index_query_fn})
    }
  end

  def sortable_by(field, pivot_field_name) do
    %{field | options: Map.merge(field.options, %{sortable_by: pivot_field_name})}
  end

  def index_fields(queried_resource, rel_name, related_resource) do
    field_name = String.to_existing_atom(rel_name)
    field = Enum.find(queried_resource.fields(), &(&1.field == field_name))
    index_fields_for_many_to_many_field(field, field_name, related_resource, queried_resource)
  end

  defp index_fields_for_many_to_many_field(
         %Field{private_options: %{index_fields: index_fields}},
         _,
         _,
         _
       ),
       do: index_fields

  defp index_fields_for_many_to_many_field(_, field_name, related_resource, queried_resource) do
    [
      ManyToManyBelongsTo.make(field_name, related_resource, queried_resource)
    ]
  end
end
