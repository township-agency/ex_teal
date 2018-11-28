defmodule ExTeal.Auth.GuestProviderTest do
  use TestExTeal.ConnCase
  alias ExTeal.Auth.Guest
  alias ExTeal.Auth.GuestProvider

  test "current_user_for/1 returns a tuple", %{conn: conn} do
    assert {:ok, %Guest{} = guest} = GuestProvider.current_user_for(conn)
  end
end
