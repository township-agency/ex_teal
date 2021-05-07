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
      Enum.reduce(resource.search(), false, fn field_name, dynamic ->
        dynamic([q], ilike(field(q, ^field_name), ^"%#{term}%") or ^dynamic)
      end)

    dynamic =
      case Integer.parse(term) do
        {id, ""} ->
          dynamic([q], q.id == ^id or ^dynamic)

        {_integer, _remainder} ->
          dynamic

        :error ->
          dynamic
      end

    from(query, where: ^dynamic)
  end
end
