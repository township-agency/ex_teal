defmodule ExTeal.FieldFilter.Text do
  @moduledoc """
  Field Filter for text fields

  Available operators are:

  * `=`
  * `!=`
  * `contains`
  * `does not contain`
  * `is empty`
  * `not empty`
  """
  @behaviour ExTeal.FieldFilter
  import Ecto.Query

  @impl true
  def operators,
    do: [
      %{"op" => "="},
      %{"op" => "!="},
      %{"op" => "contains"},
      %{"op" => "does not contain"},
      %{"op" => "is empty", "no_operand" => true},
      %{"op" => "not empty", "no_operand" => true}
    ]

  @impl true
  def interface_type, do: "text"

  @impl true
  def filter(query, %{"operator" => "=", "operand" => val}, field_name) do
    where(query, [q], field(q, ^field_name) == ^val)
  end

  def filter(query, %{"operator" => "!=", "operand" => val}, field_name) do
    where(query, [q], field(q, ^field_name) != ^val)
  end

  def filter(query, %{"operator" => "contains", "operand" => val}, field_name) do
    where(query, [q], ilike(field(q, ^field_name), ^"%#{val}%"))
  end

  def filter(query, %{"operator" => "does not contains", "operand" => val}, field_name) do
    where(query, [q], not ilike(field(q, ^field_name), ^"%#{val}%"))
  end

  def filter(query, %{"operator" => "is empty"}, field_name) do
    where(query, [q], is_nil(field(q, ^field_name)))
  end

  def filter(query, %{"operator" => "not empty"}, field_name) do
    where(query, [q], not is_nil(field(q, ^field_name)))
  end

  def filter(query, _, _), do: query
end
