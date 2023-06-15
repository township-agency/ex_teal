defmodule ExTeal.FieldFilter do
  @moduledoc """
  Functionality for gathering and parsing filters for a resource index
  based on the fields present on the resource.
  """

  alias ExTeal.Field
  alias ExTeal.Resource.Fields
  alias ExTeal.Resource.Serializer
  alias Phoenix.Naming

  @type valid_type :: module() | false

  @doc """
  Build a field filter by extending the incoming query with the following arguments:

  - The query being built (Ecto.Queryable from the Index module)
  - The configuration of the field filter as a string keyed map:
    - "operator" a string representing the operation selected by
      the user that is being performed
    - "operand" a string or map representing the value to apply against the operand and query
  - The field struct being queried
  - The resource module for the resource being queried
  """
  @callback filter(Ecto.Queryable.t(), map(), Field.t(), module()) :: Ecto.Queryable.t()

  @doc """
  Type of filter component to use in the user interface.
  """
  @callback interface_type() :: String.t() | nil

  @doc """
  Define the available operators for the filter and the behaviour of each.

  Each available operator is defined by a map with the following keys:
  - `op` (required) the operator being defined
  - `no_operand` (optional) set to true for an operator that does not require an operand.
  - `component` (optional) override the default operand component, which defaults to a string field.

  """
  @callback operators(ExTeal.Field.t()) :: [map()]

  @type serialized_filter :: %{
          required(:as) => String.t(),
          required(:field) => String.t(),
          required(:label) => String.t(),
          required(:operators) => [map()],
          optional(any()) => any()
        }

  @doc """
  Builds the map that allows the user interface to represent the field filter
  and all of it's configuration.

  Can be configured for customization on a per filter basis.
  """
  @callback serialize(Field.t(), module) :: serialized_filter()

  defmacro __using__(_opts) do
    quote do
      @behaviour ExTeal.FieldFilter
      alias ExTeal.Field

      @impl true
      def serialize(field, _resource),
        do: ExTeal.FieldFilter.default_serialization(field, interface_type(), operators(field))

      defoverridable(serialize: 2)
    end
  end

  @doc """
  Iterates over a resources fields, and serializes them into a response
  that can be used by the vue app to build some logic
  """
  def for_resource(resource, conn) do
    filters =
      resource
      |> filters_for_resource(conn)
      |> Enum.map(&to_filter(&1, resource))

    Serializer.send(conn, :index, %{filters: filters})
  end

  @doc """
  Iterate over the fields from an index query, build the related field
  filter and apply their queries.
  """
  @spec query(Ecto.Queryable.t(), list(map()), module(), Plug.Conn.t()) :: Ecto.Queryable.t()
  def query(query, filter_params, resource, conn) do
    filters =
      resource
      |> filters_for_resource(conn)
      |> Enum.into(%{}, fn %Field{field: name} = f -> {name, f} end)

    Enum.reduce(filter_params, query, &build_and_query_filter(&1, &2, filters, resource))
  end

  @doc """
  Default serialization of a field filter
  """
  def default_serialization(%Field{field: name}, interface_type, operators) do
    %{
      as: interface_type,
      field: name,
      label: name |> Naming.humanize() |> String.capitalize(),
      operators: operators
    }
  end

  defp filters_for_resource(resource, conn) do
    resource
    |> Fields.all_fields()
    |> Enum.reject(fn field ->
      is_nil(field.filterable) or field.virtual or field.filterable == false or
        not is_nil(field.embed_field)
    end)
    |> Enum.filter(&Fields.apply_can_see(&1, conn))
  end

  defp to_filter(%Field{filterable: filter_type} = field, resource) do
    filter_type.serialize(field, resource)
  end

  defp build_and_query_filter(%{"field" => f} = filter_param, query, filters, resource) do
    field = f |> String.downcase() |> String.to_existing_atom()

    case Map.get(filters, field) do
      nil ->
        query

      %Field{filterable: filter_type, embed_field: nil} = field ->
        filter_type.filter(query, filter_param, field, resource)

      %Field{filterable: filter_type} = field ->
        filter_type.embedded_filter(query, filter_param, field, resource)
    end
  end
end
