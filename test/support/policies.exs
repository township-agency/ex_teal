defmodule TestExTeal.EnoughPolicy do
  use ExTeal.Policy

  @impl true
  def create_any?(_), do: false
end

defmodule TestExTeal.VisiblePolicy do
  use ExTeal.Policy

  @impl true
  def view_any?(_), do: true
  @impl true
  def view?(_, _), do: true
end

defmodule TestExTeal.InvisiblePolicy do
  use ExTeal.Policy

  @impl true
  def view_any?(_), do: false
  @impl true
  def view?(_, _), do: false
end

defmodule TestExTeal.ImmutablePolicy do
  use ExTeal.Policy

  @impl true
  def update_any?(_), do: false
  @impl true
  def update?(_, _), do: false
end

defmodule TestExTeal.ForeverPolicy do
  use ExTeal.Policy

  @impl true
  def delete_any?(_), do: false
  @impl true
  def delete?(_, _), do: false
end
