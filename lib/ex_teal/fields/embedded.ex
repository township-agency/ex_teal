defmodule ExTeal.Embedded do
  @moduledoc """
  Generates a panel that contains the fields for a single embed, defined by its
  field name
  """

  alias ExTeal.{Field, Panel}
  alias ExTeal.Fields.Hidden

  @spec new(atom(), [Field.t()], String.t() | nil) :: Panel.t()
  def new(name, fields, label \\ nil) do
    fields =
      [Hidden.make(:id) | fields]
      |> Enum.map(fn field ->
        attr = :"#{name}.#{field.attribute}"
        %{field | attribute: attr, embed_field: name}
      end)

    name = Field.field_name(name, label)
    Panel.new(name, fields)
  end
end
