defmodule ExTeal.Resource.Query do
  @moduledoc """
  Behaviour responsible for preloading relationships
  on a resource
  """

  @callback display_title(ExTeal.record()) :: String.t()

  defmacro __using__(_) do
    quote do
      @behaviour ExTeal.Resource.Query
      alias ExTeal.Resource.Query

      def display_title(schema), do: Query.default_display_title(schema)

      defoverridable(display_title: 1)
    end
  end

  @default_title_fields ~w(title name first_name last_name)a

  def default_display_title(schema) do
    values =
      @default_title_fields
      |> Enum.map(fn field ->
        Map.get(schema, field)
      end)
      |> Enum.reject(&is_nil/1)

    case Enum.empty?(values) do
      true ->
        name = title_from_resource(schema)
        "#{name}: #{Map.get(schema, :id)}"

      false ->
        List.first(values)
    end
  end

  def apply_options(fields, model) do
    Enum.map(fields, fn field -> field.type.apply_options_for(field, model) end)
  end

  defp title_from_resource(module) do
    [_elixir, _app | rest] =
      module.__struct__
      |> to_string()
      |> String.split(".")

    [resource | _] = Enum.reverse(rest)

    resource
    |> String.replace("Resource", "")
  end
end
