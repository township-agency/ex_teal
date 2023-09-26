defmodule ExTeal.Fields.EmbedsMany do
  @moduledoc """
  Generates a panel that contains a list of cards that represent the embedded
  associations of the given schema.
  """
  use ExTeal.Field
  alias ExTeal.Fields.Hidden

  def component, do: "embeds-many-field"

  def show_on_index, do: false

  def fields(field, fields) do
    fields =
      [Hidden.make(:id)]
      |> Enum.concat(fields)
      |> Enum.map(fn field ->
        %{field | stacked: true, options: Map.put(field.options, :nested, true)}
      end)

    %{field | options: Map.put(field.options, :embed_fields, fields)}
  end

  @impl true
  def sanitize_as, do: :json

  @impl true
  def value_for(field, model, type) do
    model
    |> Map.get(field.field, [])
    |> Enum.map(fn element ->
      field.options
      |> Map.get(:embed_fields, [])
      |> Enum.map(fn embedded_field ->
        value = embedded_field.type.value_for(embedded_field, element, type)
        %{embedded_field | value: value}
      end)
    end)
  end

  @impl true
  def apply_options_for(field, _model, conn, type) do
    value =
      field
      |> Map.get(:value, [])
      |> Enum.map(fn related ->
        Enum.map(related, fn value_field ->
          value_field.type.apply_options_for(value_field, related, conn, type)
        end)
      end)

    %{field | value: value}
  end
end
