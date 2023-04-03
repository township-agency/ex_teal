defmodule ExTeal.FieldFilter.Boolean do
  @moduledoc """
  Field Filter for boolean fields

  Available operators are:

  * `true`
  * `false`
  """
  use ExTeal.FieldFilter
  import Ecto.Query

  @impl true
  def operators(_),
    do: [
      %{"op" => "true", "no_operand" => true},
      %{"op" => "false", "no_operand" => true}
    ]

  @impl true
  def interface_type, do: nil

  @impl true
  def filter(query, %{"operator" => "true"}, field, _) do
    where(query, [q], field(q, ^field.field) == true)
  end

  def filter(query, %{"operator" => "false"}, field, _) do
    where(query, [q], field(q, ^field.field) == false)
  end

  def filter(query, _, _, _), do: query
end
