defmodule DemoWeb.ExTeal.Manifest do
  use ExTeal.Manifest

  def resources,
    do: [
      DemoWeb.ExTeal.UserResource
    ]

  def plugins, do: []

  def auth_provider, do: DemoWeb.ExTeal.AuthProvider
end
