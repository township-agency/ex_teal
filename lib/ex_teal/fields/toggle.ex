defmodule ExTeal.Fields.Toggle do
  @moduledoc false
  use ExTeal.Field
  alias ExTeal.Field

  def component, do: "toggle"

  def make(name, label \\ nil) do
    field = Field.struct_from_field(__MODULE__, name, label)
    Map.put(field, :text_align, "center")
  end

  def true_value(%Field{options: options} = field, label) do
    opts = Map.merge(options, %{true_value: label})
    %{field | options: opts}
  end

  def false_value(%Field{options: options} = field, label) do
    opts = Map.merge(options, %{false_value: label})
    %{field | options: opts}
  end
end
