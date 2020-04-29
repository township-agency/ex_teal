defmodule ExTeal.FieldFilter.Date do
  @moduledoc """
  Field Filter for date fields

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
  def interface_type, do: "date"

  @impl true
  def filter(query, %{"operator" => "=", "operand" => val}, field_name, _)
      when val != "" and not is_nil(val) do
    where(query, [q], field(q, ^field_name) == ^val)
  end

  def filter(query, %{"operator" => "!=", "operand" => val}, field_name, _)
      when val != "" and not is_nil(val) do
    where(query, [q], field(q, ^field_name) != ^val)
  end

  def filter(query, %{"operator" => ">", "operand" => val}, field_name, _)
      when val != "" and not is_nil(val) do
    where(query, [q], field(q, ^field_name) > ^val)
  end

  def filter(query, %{"operator" => ">=", "operand" => val}, field_name, _)
      when val != "" and not is_nil(val) do
    where(query, [q], field(q, ^field_name) >= ^val)
  end

  def filter(query, %{"operator" => "<", "operand" => val}, field_name, _)
      when val != "" and not is_nil(val) do
    where(query, [q], field(q, ^field_name) < ^val)
  end

  def filter(query, %{"operator" => "<=", "operand" => val}, field_name, _)
      when val != "" and not is_nil(val) do
    where(query, [q], field(q, ^field_name) <= ^val)
  end

  def filter(query, %{"operator" => "is empty"}, field_name, _) do
    where(query, [q], is_nil(field(q, ^field_name)))
  end

  def filter(query, %{"operator" => "not empty"}, field_name, _) do
    where(query, [q], not is_nil(field(q, ^field_name)))
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
end
