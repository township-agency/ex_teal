defmodule ExTeal.Fields.PasswordTest do
  use ExUnit.Case
  alias ExTeal.Fields.Password

  describe "make/1" do
    test "sets the field properties" do
      field = Password.make(:password)
      assert field.attribute == "password"
      assert field.name == "Password"
    end
  end

  describe "make/2" do
    test "sets a custom name" do
      field = Password.make(:admin_password, "Admin Password")
      assert field.attribute == "admin_password"
      assert field.name == "Admin Password"
    end
  end

  test "has a component" do
    field = Password.make(:password)
    assert field.component == "password-field"
  end

  test "is shown on edit" do
    field = Password.make(:password)
    assert field.show_on_edit
  end

  test "is not shown on the index" do
    field = Password.make(:password)
    refute field.show_on_index
  end

  test "is not shown on detail" do
    field = Password.make(:password)
    refute field.show_on_detail
  end
end
