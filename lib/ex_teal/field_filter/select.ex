defmodule ExTeal.FieldFilter.Select do
  @moduledoc """
  Simple Field Filter that builds operators
  from the options stored on the field
  """

  use ExTeal.FieldFilter
  import Ecto.Query
  alias ExTeal.Fields.Select

  @impl true
  def operators(field) do
    field
    |> Select.all_options_for()
    |> Enum.map(fn %{value: value} ->
      %{"op" => value, "no_operand" => true}
    end)
  end

  @impl true
  def interface_type, do: "text"

  @impl true
  def filter(query, %{"operator" => op}, field_name, resource)
      when op != "" and not is_nil(op) do
    field = Enum.find(resource.fields(), &(&1.field == field_name))

    option =
      field
      |> Select.all_options_for()
      |> Enum.find(fn %{value: value} -> value == op end)

    case option do
      %{value: value} ->
        where(query, [q], field(q, ^field_name) == ^value)

      _ ->
        query
    end
  end

  def filter(query, op, field_name, resource) do
    IO.warn(
      "Unmatched select field filter for resource: #{resource.title} on field #{field_name} with params: #{inspect(op)}"
    )

    query
  end
end
