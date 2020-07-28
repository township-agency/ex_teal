defmodule ExTeal.Metric.Result do
  @moduledoc """
  A Data Structure returned and serialized by a successful
  Value Metric Query
  """

  @serialized ~w(data prefix suffix format multiple_results options)a
  @derive {Jason.Encoder, only: @serialized}

  alias __MODULE__

  defstruct [:data, :prefix, :suffix, :format, :multiple_results, :options]

  @type t :: %__MODULE__{}

  @spec build(module, any()) :: Result.t()
  def build(metric, data) do
    %Result{
      prefix: metric.prefix(),
      suffix: metric.suffix(),
      format: metric.format(),
      multiple_results: metric.multiple_results(),
      data: data,
      options: metric.chart_options()
    }
  end
end
