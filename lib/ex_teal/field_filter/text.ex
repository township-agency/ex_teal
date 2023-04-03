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
  use ExTeal.FieldFilter
  import Ecto.Query

  @impl true
  def operators(_),
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
  def filter(query, %{"operator" => "=", "operand" => val}, field, _)
      when val != "" and not is_nil(val) do
    where(query, [q], fragment("lower(?)", field(q, ^field.field)) == ^String.downcase(val))
  end

  def filter(query, %{"operator" => "!=", "operand" => val}, field, _)
      when val != "" and not is_nil(val) do
    where(query, [q], fragment("lower(?)", field(q, ^field.field)) != ^String.downcase(val))
  end

  def filter(query, %{"operator" => "contains", "operand" => val}, field, _)
      when val != "" and not is_nil(val) do
    where(query, [q], ilike(field(q, ^field.field), ^"%#{val}%"))
  end

  def filter(query, %{"operator" => "does not contains", "operand" => val}, field, _)
      when val != "" and not is_nil(val) do
    where(query, [q], not ilike(field(q, ^field.field), ^"%#{val}%"))
  end

  def filter(query, %{"operator" => "is empty"}, field, _) do
    where(query, [q], is_nil(field(q, ^field.field)))
  end

  def filter(query, %{"operator" => "not empty"}, field, _) do
    where(query, [q], not is_nil(field(q, ^field.field)))
  end

  def filter(query, _, _, _), do: query
end
