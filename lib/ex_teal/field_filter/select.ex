defmodule ExTeal.FieldFilter.Select do
  @moduledoc """
  Simple Field Filter that builds operators
  from the options stored on the field
  """

  use ExTeal.FieldFilter
  import Ecto.Query

  @impl true
  def operators(field) do
    field
    |> Map.get(:options, [])
    |> Enum.map(fn {_value, label} ->
      %{"op" => label, "no_operand" => true}
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
      |> Map.get(:options, [])
      |> Enum.find(fn {_k, label} -> label == op end)

    case option do
      {k, _} ->
        where(query, [q], field(q, ^field_name) == ^k)

      _ ->
        query
    end
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
