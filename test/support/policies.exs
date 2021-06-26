defmodule TestExTeal.EnoughPolicy do
  use ExTeal.Policy

  @impl true
  def create_any?(_), do: false
end

defmodule TestExTeal.InvisiblePolicy do
  use ExTeal.Policy

  @impl true
  def view_any?(_), do: false
end

defmodule TestExTeal.ImmutablePolicy do
  use ExTeal.Policy

  @impl true
  def update_any?(_), do: false
end

defmodule TestExTeal.ForeverPolicy do
  use ExTeal.Policy

  @impl true
  def delete_any?(_), do: false
end
