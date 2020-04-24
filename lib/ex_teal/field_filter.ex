defmodule ExTeal.FieldFilter do
  @moduledoc """
  Functionality for gathering and parsing filters for a resource index
  based on the fields present on the resource.
  """

  alias ExTeal.Field
  alias ExTeal.Resource.Fields
  alias ExTeal.Resource.Serializer
  alias Phoenix.Naming

  @doc """
  Build a field filter by extending the incoming query with the following arguments:

  - The query being built (Ecto.Queryable from the Index module)
  - The configuration of the field filter as a string keyed map:
    - "operator" a string representing the operation selected by
      the user that is being performed
    - "operand" a string or map representing the value to apply against the operand and query
  - An atom representing the name of the field being queried.
  """
  @callback filter(Ecto.Queryable.t(), map(), atom()) :: Ecto.Queryable.t()

  @doc """
  Type of filter component to use in the user interface.
  """
  @callback interface_type() :: String.t()

  @doc """
  Define the available operators for the filter and the behaviour of each.

  Each available operator is defined by a map with the following keys:
  - `op` (required) the operator being defined
  - `no_operand` (optional) set to true for an operator that does not require an operand.
  - `component` (optional) override the default operand component, which defaults to a string field.

  """
  @callback operators() :: [map()]

  @doc """
  Iterates over a resources fields, and serializes them into a response
  that can be used by the vue app to build some logic
  """
  def for_resource(resource, conn) do
    filters =
      resource
      |> filters_for_resource()
      |> Enum.map(&to_filter/1)

    Serializer.send(conn, :index, %{filters: filters})
  end

  @doc """
  Iterate over the fields from an index query, build the related field
  filter and apply their queries.
  """
  @spec query(Ecto.Queryable.t(), map(), module()) :: Ecto.Queryable.t()
  def query(query, filter_params, resource) do
    filters =
      resource
      |> filters_for_resource()
      |> Enum.into(%{}, fn %Field{field: name} = f -> {name, f} end)

    Enum.reduce(filter_params, query, &build_and_query_filter(&1, &2, filters))
  end

  defp filters_for_resource(resource) do
    resource
    |> Fields.all_fields()
    |> Enum.filter(& &1.filterable)
  end

  defp to_filter(%Field{filterable: filter_type, field: name}) do
    %{
      as: filter_type.interface_type(),
      field: name,
      label: name |> Naming.humanize() |> String.capitalize(),
      operators: filter_type.operators()
    }
  end

  defp build_and_query_filter(%{"field" => f} = filter_param, query, filters) do
    field = f |> String.downcase() |> String.to_existing_atom()

    case Map.get(filters, field) do
      nil ->
        query

      %Field{filterable: filter_type} ->
        filter_type.filter(query, filter_param, field)
    end
  end
end
