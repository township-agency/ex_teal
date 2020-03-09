defmodule ExTeal.Auth.GuestProviderTest do
  use TestExTeal.ConnCase
  alias ExTeal.Auth.GuestProvider

  test "current_user_for/1 returns a tuple", %{conn: conn} do
    guest = GuestProvider.current_user_for(conn)
    refute guest.name
    refute guest.avatar_url
  end
end
