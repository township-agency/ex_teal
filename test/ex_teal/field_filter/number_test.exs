defmodule ExTeal.FieldFilter.NumberTest do
  use TestExTeal.ConnCase

  alias ExTeal.FieldFilter.Number
  alias ExTeal.Fields.Number, as: NumberField
  alias TestExTeal.{Order, OrderResource}

  test "interface_type is text" do
    assert Number.interface_type() == "number"
  end

  describe "filter/3" do
    test "=" do
      %Order{id: id} = insert(:order, grand_total: 10)
      [result] = find_order("=", "10")
      assert result.id == id
    end

    test "!=" do
      %{id: _id} = insert(:order, grand_total: 10)
      %{id: id_b} = insert(:order, grand_total: 8)
      [result] = find_order("!=", "10")
      assert result.id == id_b
    end

    test "numeric comparison" do
      order_10 = insert(:order, grand_total: 10)
      order_20 = insert(:order, grand_total: 20)

      assert [order_10] == find_order("<", "11")
      assert [order_10] == find_order("<=", "10")
      assert [order_20] == find_order(">", "10")
      assert [order_20] == find_order(">=", "20")
    end

    test "is empty" do
      %{id: id} = insert(:order, grand_total: nil)
      %{id: id2} = insert(:order, grand_total: 10)
      [result] = find_order("is empty")
      [result_2] = find_order("not empty")
      assert result.id == id
      assert result_2.id == id2
    end

    defp find_order(op) do
      f = NumberField.make(:grand_total)

      Order
      |> Number.filter(%{"operator" => op}, f, OrderResource)
      |> Repo.all()
    end

    defp find_order(op, operand) do
      f = NumberField.make(:grand_total)

      Order
      |> Number.filter(%{"operator" => op, "operand" => operand}, f, OrderResource)
      |> Repo.all()
    end
  end
end
