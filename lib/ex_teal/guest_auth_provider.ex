defmodule ExTeal.GuestAuthProvider do
  @moduledoc """
  The default auth provider that allows all access to ExTeal.  Should not be
  used in production!
  """

  use ExTeal.AuthProvider
end
