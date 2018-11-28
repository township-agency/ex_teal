defmodule ExTeal.GlobalSearchTest do
  use TestExTeal.ConnCase

  alias ExTeal.GlobalSearch

  describe "new/2" do
    test "it returns a global search struct which stores the conn and the resources", %{
      conn: conn
    } do
      result = GlobalSearch.new(conn, [TestExTeal.UserResource])
      assert result == %GlobalSearch{conn: conn, resources: [TestExTeal.UserResource]}
    end
  end
end
