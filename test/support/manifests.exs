defmodule TestExTeal.DefaultManifest do
  use ExTeal.Manifest

  def resources,
    do: [
      TestExTeal.UserResource,
      TestExTeal.PostResource
    ]

  def plugins, do: []
end
