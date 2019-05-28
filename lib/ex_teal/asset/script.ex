defmodule ExTeal.Asset.Script do
  @moduledoc """
  Struct used to represent a JS Script
  that is served by Teal and required by a plugin
  on the front end side.
  """

  defstruct [:plugin_uri, :path]
end
