defmodule ExTeal.Asset.Style do
  @moduledoc """
  Struct used to represent a CSS Stylesheet
  that is served by Teal and required by a plugin
  on the front end.
  """

  defstruct [:plugin_uri, :path]

  @type t :: %__MODULE__{}
end
