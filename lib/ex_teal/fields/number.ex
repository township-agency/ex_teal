defmodule ExTeal.Fields.Number do
  @moduledoc false
  use ExTeal.Field

  def component, do: "number-field"

  def with_options(field, options) when is_map(options) do
    %{field | options: options}
  end
end
