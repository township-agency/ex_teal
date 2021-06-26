defmodule ExTeal.OpenEverywherePolicy do
  @moduledoc """
  The default policy that allows authenticated users access to CRUD.
  All callbacks default to always being true. Should not be used in production!
  """

  use ExTeal.Policy
end
