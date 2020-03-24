defmodule ExTeal.FieldFilter do
  @moduledoc """
  Functionality for gathering and parsing filters for a resource index
  based on the fields present on the resource.
  """

  alias ExTeal.Field
  alias ExTeal.Resource.Fields
  alias ExTeal.Resource.Serializer

  @type valid_type :: :number | :string | false

  @doc """
  Iterates over a resources fields, and serializes them into a response
  that can be used by the vue app to build some logic
  """
  def for_resource(resource, conn) do
    filters =
      resource
      |> Fields.all_fields()
      |> Enum.filter(& &1.filterable)
      |> Enum.map(&to_filter/1)

    Serializer.send(conn, :index, %{filters: filters})
  end

  defp to_filter(%Field{filterable: filter_type, field: name}) do
    %{as: filter_type, field: name}
  end
end
