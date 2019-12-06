defmodule ExTeal.Fields.Date do
  @moduledoc """
  The `Date` field may be used to generate a calendar date select.

  The date format for display on the index and detail views may be defined using the `Select.with_options/2` function:

      Date.make(:date)
      |> Date.with_options(%{"format" => "YYYY/MM/DD"})
  """

  use ExTeal.Field

  def component, do: "date"

  @valid_date_formats ~w(short med full huge)a

  @type valid_format :: :short | :med | :full | :huge

  @doc """
  Set the format that the date is rendered with on the detail and index components.

  Uses [luxon's toLocaleString](https://moment.github.io/luxon/docs/manual/formatting.html#tolocalestring--strings-for-humans-)
  to display the date in a localized format:

  Examples:

  :short
  en_US -> 10/14/1983
  fr    -> 14/10/1983

  :med
  en_US -> Oct 14, 1983
  fr    -> 14 oct. 1983

  :full 
  en_US -> October 14, 1983
  fr    -> 14 octobre 1983

  :huge
  en_US -> Tuesday, October 14, 1983
  fr    -> vendredi 14 octobre 1983
  """
  @spec format(Field.t(), valid_format()) :: Field.t()
  def format(%Field{options: options} = field, format) when format in @valid_date_formats do
    %{field | options: Map.put(options, :format, "date_#{Atom.to_string(format)}")}
  end

  @doc """
  Set the format that flatpickr will render the date in on forms. 

  Format should be a string of [flatpickr tokens](https://flatpickr.js.org/formatting/)
  """
  def picker_format(%Field{options: options} = field, format) when is_bitstring(format),
    do: %{field | options: Map.put(options, :picker_format, format)}

  @deprecated "Use Date.format/2 and Date.picker_format/2 instead"
  def with_options(field, options) when is_map(options) do
    %{field | options: options}
  end
end
