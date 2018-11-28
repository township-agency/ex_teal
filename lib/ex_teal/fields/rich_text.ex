defmodule ExTeal.Fields.RichText do
  @moduledoc false
  use ExTeal.Field

  def component, do: "rich-text"

  def show_on_index, do: false
end
