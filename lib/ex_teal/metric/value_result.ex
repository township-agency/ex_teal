defmodule ExTeal.Metric.ValueResult do
  @moduledoc """
  A Data Structure returned and serialized by a successful
  Value Metric Query
  """

  @serialized ~w(uri current previous ranges range prefix suffix)a
  @derive {Jason.Encoder, only: @serialized}

  defstruct [:uri, :current, :previous, :ranges, :range, :prefix, :suffix, :format]

  @type t :: %__MODULE__{}
end
