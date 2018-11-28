defmodule ExTeal.Fields.Password do
  @moduledoc false
  use ExTeal.Field

  def component, do: "password-field"

  def show_on_index, do: false
  def show_on_detail, do: false
end
