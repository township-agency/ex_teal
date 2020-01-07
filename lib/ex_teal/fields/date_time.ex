defmodule ExTeal.Fields.DateTime do
  @moduledoc false

  use ExTeal.Field

  def component, do: "date-time"

  @doc """
  Set the format of the flatpickr datetime picker.

  See the [flatpickr docs](https://flatpickr.js.org/formatting/) for the options
  """
  def picker_format(%Field{options: options} = field, value) do
    %{field | options: Map.put_new(options, :picker_format, value)}
  end

  def twenty_four_hour_time(%Field{options: options} = field) do
    %{field | options: Map.put_new(options, :twenty_four_hour_time, true)}
  end

  @valid_datetime_formats ~w(
    date_short date_med date_full date_huge time_simple time_with_seconds
    time_with_short_offset time_with_long_offset time_24_simple time_24_with_seconds
    time_24_with_short_offset time_24_with_long_offset datetime_short datetime_med
    datetime_full datetime_huge datetime_short_with_seconds datetime_med_with_seconds
    datetime_full_with_seconds datetime_huge_with_seconds
  )a

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
  def format(%Field{options: options} = field, value) when value in @valid_datetime_formats do
    %{field | options: Map.put_new(options, :format, value)}
  end

  def value_for(%Field{} = field, model, _view) do
    case Map.get(model, field.field) do
      nil ->
        nil

      %NaiveDateTime{} = naive ->
        DateTime.from_naive!(naive, "Etc/UTC")

      val ->
        val
    end
  end
end