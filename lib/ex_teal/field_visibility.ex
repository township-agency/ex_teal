defmodule ExTeal.FieldVisibility do
  @moduledoc """
  Functions that allow a resource to configure
  which fields can be displayed on which parts
  of the resource.
  """

  alias ExTeal.Field

  @doc """
  Field is only visible on Details and Index
  """
  @spec except_on_forms(Field.t()) :: Field.t()
  def except_on_forms(field),
    do: %{
      field
      | show_on_detail: true,
        show_on_edit: false,
        show_on_index: true,
        show_on_new: false
    }

  @doc """
  Hide field is hidden on the index
  """
  @spec hide_from_index(Field.t()) :: Field.t()
  def hide_from_index(field), do: %{field | show_on_index: false}

  @doc """
  Show field on the index
  """
  @spec show_on_index(Field.t()) :: Field.t()
  def show_on_index(field), do: %{field | show_on_index: true}

  @doc """
  Hide field is hidden on the detail
  """
  @spec hide_from_detail(Field.t()) :: Field.t()
  def hide_from_detail(field), do: %{field | show_on_detail: false}

  @doc """
  Hide field is hidden when updating a resource
  """
  @spec hide_when_updating(Field.t()) :: Field.t()
  def hide_when_updating(field), do: %{field | show_on_edit: false}

  @doc """
  Hide field is hidden when creating a resource
  """
  @spec hide_when_creating(Field.t()) :: Field.t()
  def hide_when_creating(field), do: %{field | show_on_new: false}

  @doc """
  Field is only visible on Details
  """
  @spec only_on_details(Field.t()) :: Field.t()
  def only_on_details(field),
    do: %{
      field
      | show_on_detail: true,
        show_on_edit: false,
        show_on_index: false,
        show_on_new: false
    }

  @doc """
  Field is only visible on Create and New
  """
  @spec only_on_forms(Field.t()) :: Field.t()
  def only_on_forms(field),
    do: %{
      field
      | show_on_detail: false,
        show_on_edit: true,
        show_on_index: false,
        show_on_new: true
    }

  @doc """
  Field is only visible on Index
  """
  @spec only_on_index(Field.t()) :: Field.t()
  def only_on_index(field),
    do: %{
      field
      | show_on_detail: false,
        show_on_edit: false,
        show_on_index: true,
        show_on_new: false
    }

  @doc """
  Marks a relational field as searchable

  Only applies to many to many relationships
  """
  @spec searchable(Field.t()) :: Field.t()
  def searchable(%Field{type: ExTeal.Field.ManyToMany} = field),
    do: put_in(field, [:options, :searchable], true)

  def searchable(field), do: field
end
