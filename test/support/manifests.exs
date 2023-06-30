defmodule TestExTeal.DefaultManifest do
  use ExTeal.Manifest

  def resources,
    do: [
      TestExTeal.UserResource,
      TestExTeal.PostResource,
      TestExTeal.TagResource,
      TestExTeal.SinglePostUserResource,
      TestExTeal.PostEmbedResource
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

defmodule TestExTeal.InvisibleManifest do
  use ExTeal.Manifest

  def resources,
    do: [TestExTeal.UserResource, TestExTeal.Invisible.PostResource, TestExTeal.TagResource]
end

defmodule TestExTeal.EnoughManifest do
  use ExTeal.Manifest

  def resources,
    do: [TestExTeal.UserResource, TestExTeal.Enough.PostResource, TestExTeal.TagResource]
end

defmodule TestExTeal.ImmutableManifest do
  use ExTeal.Manifest

  def resources,
    do: [TestExTeal.UserResource, TestExTeal.Immutable.PostResource, TestExTeal.TagResource]
end

defmodule TestExTeal.ForeverManifest do
  use ExTeal.Manifest

  def resources,
    do: [TestExTeal.UserResource, TestExTeal.Forever.PostResource, TestExTeal.TagResource]
end

defmodule TestExTeal.PostCountManifest do
  use ExTeal.Manifest
  def resources, do: [TestExTeal.UsersWithPostCountsResource, TestExTeal.PostResource]
end
