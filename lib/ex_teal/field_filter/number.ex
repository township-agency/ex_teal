defmodule ExTeal.FieldFilter.Number do
  @moduledoc """
  Field Filter for number fields

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
  def interface_type, do: "number"

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
end
