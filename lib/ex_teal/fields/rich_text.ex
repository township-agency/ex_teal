defmodule ExTeal.Fields.RichText do
  @moduledoc false
  use ExTeal.Field

  def component, do: "rich-text"

  def show_on_index, do: false

  def sanitize_as, do: :html5

  def as_html, do: true
end
