defmodule ExTeal.Fields.RichText do
  @moduledoc false
  use ExTeal.Field

  def component, do: "rich-text"

  def filterable_as, do: ExTeal.FieldFilter.Text

  def show_on_index, do: false

  def sanitize_as, do: :html5

  def as_html, do: true

  @doc """
  Enable File Uploads for this field.  This assumes you've configured a plugin that handles and exposes
  file uploading functionality to the vue app.
  """
  def with_files(field), do: %{field | options: Map.put(field.options, :with_files, true)}
end
