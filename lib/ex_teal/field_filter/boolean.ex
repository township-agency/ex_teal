defmodule ExTeal.FieldFilter.Boolean do
  @moduledoc """
  Field Filter for boolean fields

  Available operators are:

  * `true`
  * `false`
  """
  @behaviour ExTeal.FieldFilter
  import Ecto.Query

  @impl true
  def operators,
    do: [
      %{"op" => "true", "no_operand" => true},
      %{"op" => "false", "no_operand" => true}
    ]

  @impl true
  def interface_type, do: nil

  @impl true
  def filter(query, %{"operator" => "true"}, field_name) do
    where(query, [q], field(q, ^field_name) == true)
  end

  def filter(query, %{"operator" => "false"}, field_name) do
    where(query, [q], field(q, ^field_name) == false)
  end

  def filter(query, _, _), do: query
end
