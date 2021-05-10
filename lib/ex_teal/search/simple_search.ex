defmodule ExTeal.Search.SimpleSearch do
  @moduledoc """
  The default search adapter.  Uses dynamic ecto queries to build a simple
  ILIKE comparison across the field specified by the `search/2` function on
  the resource.
  """
  import Ecto.Query

  @doc """
  Build a dynamic ecto where statement by reducing over the resource's
  searchable fields and creating an ilike where expression
  """
  @spec build(Ecto.Query.t(), module(), map()) :: Ecto.Query.t()
  def build(query, resource, %{"search" => term}) do
    dynamic =
      Enum.reduce([:id | resource.search()], false, fn field_name, dynamic ->
        dynamic([q], ilike(type(field(q, ^field_name), :string), ^"%#{term}%") or ^dynamic)
      end)

    from(query, where: ^dynamic)
  end
end
