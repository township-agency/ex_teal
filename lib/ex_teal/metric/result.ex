defmodule ExTeal.Metric.Result do
  @moduledoc """
  A Data Structure returned and serialized by a successful
  Value Metric Query
  """

  @serialized ~w(uri data ranges range prefix suffix format)a
  @derive {Jason.Encoder, only: @serialized}

  alias __MODULE__

  defstruct [:uri, :data, :ranges, :range, :prefix, :suffix, :format]

  @type t :: %__MODULE__{}

  @spec base_result(module, ExTeal.Metric.Request.t()) :: Result.t()
  def base_result(metric, request) do
    %Result{
      uri: metric.uri(),
      ranges: metric.ranges(),
      range: request.range,
      prefix: metric.prefix(),
      suffix: metric.suffix(),
      format: metric.format()
    }
  end

  @spec put_data(t) :: t
  def put_data(%Result{} = result, data \\ %{}) do
    Map.put(result, :data, data)
  end
end
