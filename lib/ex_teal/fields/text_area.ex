defmodule ExTeal.Fields.TextArea do
  @moduledoc false
  use ExTeal.Field

  def component, do: "text-area"

  def show_on_index, do: false
end
