defmodule ExTeal.Metric do
  @moduledoc """
  Describes the behaviour of a metric with specific callbacks for
  building a base result, calculating the values, applying then and returning
  the result
  """

  @type unit :: :minute | :hour | :day | :week | :month | :year

  @type range :: %{
          label: String.t(),
          unit: unit(),
          value: integer()
        }

  @callback date_field() :: atom()
  @callback date_field_type() :: :naive_datetime | :utc_datetime
  @callback multiple_results() :: boolean()

  @doc """
  Explicitly set the uri used to fetch the details of a card.
  """
  @callback uri() :: String.t()

  @doc """
  Set the title displayed at the top of the card, defaults
  to a humanized title of the module
  """
  @callback title :: String.t()

  @doc """
  Set the width of card that displays the metric.  Defaults to 1/3.
  1/3 and full are the only allowed values
  """
  @callback width :: String.t()

  @doc """
  Only display the metric on the detail page of a specific resource.
  """
  @callback only_on_detail(Plug.Conn.t()) :: boolean()

  @doc """
  Only display the metric on the index page of a specific resource.
  """
  @callback only_on_index(Plug.Conn.t()) :: boolean()

  @doc """
  A string to prepend to any displayed value on the metric card. For example: `$`
  """
  @callback prefix() :: String.t() | nil

  @doc """
  A string to appended to any displayed value on the metric card.  For example: `°`
  """
  @callback suffix() :: String.t() | nil

  @doc """
  A string representing how a value is formatted before being displayed by the
  [numbro](https://numbrojs.com/) library.  Defaults to `0,0`
  """
  @callback format() :: String.t()

  @doc """
  The name of the component to mount in the ux responsible for rendering
  the content
  """
  @callback component() :: String.t()

  @doc """
  Define which ranges are available for a metric.

  Defaults to `Metric.default_ranges/0` but can be overriden per metric.
  """
  @callback ranges() :: [range()]

  @doc """
  Define the options that are passed as a metrics options map as it's
  returned as part of a metric result.
  """
  @callback chart_options() :: map()

  @doc """
  Options that are serialized into the configuration of a metric card.

  Used as part of a dashboard or card list on a resource index or detail page.
  """
  @callback options() :: map()

  @doc """
  Define the range to render by default for a metric.
  """
  @callback default_range() :: range()

  defmacro __using__(_) do
    quote do
      use ExTeal.Resource.Repo
      @behaviour ExTeal.Metric

      def date_field, do: :inserted_at

      def date_field_type, do: :naive_datetime

      def multiple_results, do: false

      def ranges, do: ExTeal.Metric.default_ranges()

      def default_range, do: %{label: "24H", unit: :hour, value: 24}

      def uri, do: ExTeal.Naming.resource_name(__MODULE__)

      def title do
        __MODULE__
        |> ExTeal.Naming.resource_name()
        |> ExTeal.Naming.humanize()
      end

      def width, do: "1/3"

      def only_on_index(_conn), do: false

      def only_on_detail(_conn), do: false

      def prefix, do: nil

      def suffix, do: nil

      def format, do: "0,0"

      def component, do: "empty-metric"

      def chart_options, do: %{}

      def options,
        do: %{
          ranges: ranges(),
          default_range: default_range(),
          uri: uri(),
          title: title(),
          format: format()
        }

      defoverridable(
        multiple_results: 0,
        date_field_type: 0,
        date_field: 0,
        ranges: 0,
        uri: 0,
        title: 0,
        width: 0,
        only_on_detail: 1,
        only_on_index: 1,
        prefix: 0,
        suffix: 0,
        format: 0,
        component: 0,
        chart_options: 0,
        options: 0,
        default_range: 0
      )
    end
  end

  @spec default_ranges() :: [range()]
  def default_ranges,
    do: [
      %{label: "60m", unit: :minute, value: 60},
      %{label: "24H", unit: :hour, value: 24},
      %{label: "7D", unit: :day, value: 7},
      %{label: "14D", unit: :day, value: 14},
      %{label: "4W", unit: :week, value: 4},
      %{label: "3M", unit: :month, value: 3},
      %{label: "6M", unit: :month, value: 6},
      %{label: "1Y", unit: :month, value: 12},
      %{label: "3Y", unit: :year, value: 3}
    ]
end
