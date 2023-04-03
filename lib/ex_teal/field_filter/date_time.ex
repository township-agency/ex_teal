defmodule ExTeal.FieldFilter.DateTime do
  @moduledoc """
  Field Filter for date time fields

  Available operators are:

  * `=`
  * `!=`
  * `>`
  * `>=`
  * `<`
  * `<=`
  * `is empty`
  * `not empty`
  """
  use ExTeal.FieldFilter
  import Ecto.Query
  alias ExTeal.FieldFilter

  @impl true
  def operators(_),
    do: [
      %{"op" => "="},
      %{"op" => "!="},
      %{"op" => ">"},
      %{"op" => ">="},
      %{"op" => "<"},
      %{"op" => "<="},
      %{"op" => "is empty", "no_operand" => true},
      %{"op" => "not empty", "no_operand" => true}
    ]

  @impl true
  def interface_type, do: "date-time"

  @impl true
  def filter(query, %{"operator" => "=", "operand" => val}, field, resource)
      when val != "" and not is_nil(val) do
    val = value_cast_to_field_type(resource, field, val)
    where(query, [q], field(q, ^field.field) == ^val)
  end

  def filter(query, %{"operator" => "!=", "operand" => val}, field, resource)
      when val != "" and not is_nil(val) do
    val = value_cast_to_field_type(resource, field, val)
    where(query, [q], field(q, ^field.field) != ^val)
  end

  def filter(query, %{"operator" => ">", "operand" => val}, field, resource)
      when val != "" and not is_nil(val) do
    val = value_cast_to_field_type(resource, field, val)
    where(query, [q], field(q, ^field.field) > ^val)
  end

  def filter(query, %{"operator" => ">=", "operand" => val}, field, resource)
      when val != "" and not is_nil(val) do
    val = value_cast_to_field_type(resource, field, val)
    where(query, [q], field(q, ^field.field) >= ^val)
  end

  def filter(query, %{"operator" => "<", "operand" => val}, field, resource)
      when val != "" and not is_nil(val) do
    val = value_cast_to_field_type(resource, field, val)
    where(query, [q], field(q, ^field.field) < ^val)
  end

  def filter(query, %{"operator" => "<=", "operand" => val}, field, resource)
      when val != "" and not is_nil(val) do
    val = value_cast_to_field_type(resource, field, val)
    where(query, [q], field(q, ^field.field) <= ^val)
  end

  def filter(query, %{"operator" => "is empty"}, field, _) do
    where(query, [q], is_nil(field(q, ^field.field)))
  end

  def filter(query, %{"operator" => "not empty"}, field, _) do
    where(query, [q], not is_nil(field(q, ^field.field)))
  end

  def filter(query, _, _, _), do: query

  @impl true
  def serialize(field, _resource) do
    defaults = FieldFilter.default_serialization(field, interface_type(), operators(field))

    Map.merge(
      defaults,
      %{
        format: Map.get(field.options, :format),
        picker_format: Map.get(field.options, :picker_format),
        placeholder: Map.get(field.options, :placeholder)
      }
    )
  end

  def value_cast_to_field_type(resource, field, val) do
    type = resource.model().__schema__(:type, field.field)

    case type do
      :naive_datetime ->
        {:ok, dt, _offset} = DateTime.from_iso8601(val)
        DateTime.to_naive(dt)

      :utc_datetime ->
        {:ok, dt, _offset} = DateTime.from_iso8601(val)
        dt
    end
  end
end
