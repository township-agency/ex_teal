defmodule TestExTeal.DefaultManifest do
  use ExTeal.Manifest

  def resources,
    do: [
      TestExTeal.UserResource,
      TestExTeal.PostResource,
      TestExTeal.TagResource
    ]

  def dashboards,
    do: [
      TestExTeal.MainDashboard
    ]

  def plugins, do: []
end

defmodule TestExTeal.EmptyManifest do
  use ExTeal.Manifest
  def resources, do: []
end

defmodule TestExTeal.MetricManifest do
  use ExTeal.Manifest
  def resources, do: []

  def dashboards,
    do: [
      TestExTeal.MainDashboard
    ]
end
