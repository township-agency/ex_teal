defmodule ExTeal.Fields.EmbedsManyTest do
  use TestExTeal.ConnCase
  alias TestExTeal.Song
  alias ExTeal.Fields.{Boolean, EmbedsMany, Number, Text}

  describe "value_for/3" do
    test "generates a group of fields for each item in the collection" do
      field =
        EmbedsMany.make(:items)
        |> EmbedsMany.fields([
          Number.make(:quantity),
          Boolean.make(:in_stock),
          Text.make(:description)
        ])

      [r1, r2] =
        EmbedsMany.value_for(
          field,
          %{
            items: [
              %{id: 1, quantity: 1, in_stock: true, description: "foo"},
              %{id: 2, quantity: 2, in_stock: false, description: "bar"}
            ]
          },
          :index
        )

      assert length(r1) == 4
      assert Enum.map(r1, & &1.field) == ~w(id quantity in_stock description)a
      assert Enum.map(r1, & &1.value) == [1, "1", true, "foo"]
      assert Enum.map(r2, & &1.value) == [2, "2", false, "bar"]
    end

    test "can generate values for nested embeds manys" do
      field =
        EmbedsMany.make(:items)
        |> EmbedsMany.fields([
          Text.make(:description),
          EmbedsMany.make(:sub_items)
          |> EmbedsMany.fields([
            Text.make(:name)
          ])
        ])

      [r1, r2] =
        EmbedsMany.value_for(
          field,
          %{
            items: [
              %{id: 1, description: "foo", sub_items: [%{id: 1, name: "foo"}]},
              %{id: 2, description: "bar", sub_items: []}
            ]
          },
          :index
        )

      assert Enum.map(r1, & &1.field) == ~w(id description sub_items)a
      [_id, _description, sub_items] = r1

      assert length(sub_items.value) == 1
      [sub_1] = sub_items.value
      assert Enum.map(sub_1, & &1.field) == ~w(id name)a
      assert Enum.map(sub_1, & &1.value) == [1, "foo"]
      assert Enum.map(r2, & &1.value) == [2, "bar", []]
    end
  end

  describe "apply_options_for/4" do
    test "can handle a new struct", %{conn: conn} do
      field =
        EmbedsMany.make(:musicians)
        |> EmbedsMany.fields([
          Text.make(:name),
          Text.make(:instrument)
        ])

      updated_field = EmbedsMany.apply_options_for(field, %Song{}, conn, :new)
      assert updated_field.value == []
    end

    test "can handle update fields", %{conn: conn} do
      field =
        EmbedsMany.make(:musicians)
        |> EmbedsMany.fields([
          Text.make(:name),
          Text.make(:instrument)
        ])

      s = insert(:song)
      updated_field = EmbedsMany.apply_options_for(field, s, conn, :new)
      assert length(updated_field.value) == 4
      [musician | _others] = updated_field.value
      assert Enum.map(musician, & &1.field) == ~w(id name instrument)a
    end
  end
end
