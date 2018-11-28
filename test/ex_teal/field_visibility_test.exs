defmodule ExTeal.FieldVisibilityTest do
  use ExUnit.Case
  import ExTeal.FieldVisibility
  alias ExTeal.Fields.Text

  setup do
    {:ok, field: Text.make(:test)}
  end

  test "only_on_details/1", %{field: field} do
    result = only_on_details(field)
    assert result.show_on_detail
    refute result.show_on_edit
    refute result.show_on_index
    refute result.show_on_new
  end

  test "only_on_forms/1", %{field: field} do
    result = only_on_forms(field)
    refute result.show_on_detail
    assert result.show_on_edit
    refute result.show_on_index
    assert result.show_on_new
  end

  test "only_on_index/1", %{field: field} do
    result = only_on_index(field)
    refute result.show_on_detail
    refute result.show_on_edit
    assert result.show_on_index
    refute result.show_on_new
  end

  test "except_on_forms/1", %{field: field} do
    result = except_on_forms(field)
    assert result.show_on_detail
    refute result.show_on_edit
    assert result.show_on_index
    refute result.show_on_new
  end

  test "hide_from_index/1", %{field: field} do
    result = hide_from_index(field)
    assert result.show_on_detail
    assert result.show_on_edit
    refute result.show_on_index
    assert result.show_on_new
  end

  test "hide_from_detail/1", %{field: field} do
    result = hide_from_detail(field)
    refute result.show_on_detail
    assert result.show_on_edit
    assert result.show_on_index
    assert result.show_on_new
  end

  test "hide_when_updating/1", %{field: field} do
    result = hide_when_updating(field)
    assert result.show_on_detail
    refute result.show_on_edit
    assert result.show_on_index
    assert result.show_on_new
  end

  test "hide_when_creating/1", %{field: field} do
    result = hide_when_creating(field)
    assert result.show_on_detail
    assert result.show_on_edit
    assert result.show_on_index
    refute result.show_on_new
  end
end
