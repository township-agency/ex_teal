defmodule ExTeal.Fields.Select do
  @moduledoc """
  The `Select` field may be used to generate a drop-down select menu.

  The select menu's options may be defined using the `Select.with_options/2` function:

      Select.make(:size)
      |> Select.with_options(%{"S" => "Small", "M" => "Medium"})

  On the resource index and detail screens, the `Select` fields "key" value will be displayed.  If you
  would like to display the labels instead, you may use the `Select.display_using_labels/1` function

      Select.make(:size)
      |> Select.with_options(%{"S" => "Small", "M" => "Medium"})
      |> Select.display_using_labels()

  You can also pass a function as the second argument to `with_options` to gather a dynamic list of
  select options:

      Select.make(:country)
      |> Select.with_options(fn() ->
        Country
        |> Repo.all()
        |> Enum.map(fn(country) ->
          {country.code, country.title}
        end)
      end)
  """

  use ExTeal.Field

  def component, do: "select"

  def with_options(field, options) when is_map(options) do
    %{field | options: options, private_options: %{display_using_labels: false}}
  end

  def with_options(field, options_fn) when is_function(options_fn) do
    options = options_fn.()
    with_options(field, options)
  end

  def display_using_labels(field) do
    opts = %{field.private_options | display_using_labels: true}
    %{field | private_options: opts}
  end

  def value_for(%Field{private_options: %{display_using_labels: true}} = field, model, view)
      when view in [:show, :index] do
    Map.get(field.options, Map.get(model, field.field))
  end

  def value_for(field, model, view), do: Field.value_for(field, model, view)

  def filterable_as, do: ExTeal.FieldFilter.Select
end
