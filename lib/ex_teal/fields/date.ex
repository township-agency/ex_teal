defmodule ExTeal.Fields.Date do
  @moduledoc """
  The `Date` field may be used to generate a calendar date select.

  The date format for display on the index and detail views may be defined using the `Select.with_options/2` function:

      Date.make(:date)
      |> Date.with_options(%{"format" => "YYYY/MM/DD"})
  """

  use ExTeal.Field

  def component, do: "date"

  def with_options(field, options) when is_map(options) do
    %{field | options: options}
  end
end
