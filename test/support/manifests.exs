defmodule TestExTeal.DefaultManifest do
  use ExTeal.Manifest

  def resources,
    do: [
      TestExTeal.UserResource,
      TestExTeal.PostResource,
      TestExTeal.TagResource
    ]

  def plugins, do: []
end
