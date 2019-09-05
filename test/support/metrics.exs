defmodule TestExTeal.NewUsersMetric do
  use ExTeal.Metric.Value

  def calculate(request) do
    count(request, TestExTeal.User)
  end

  def ranges,
    do: %{
      1 => "Daily",
      30 => "30 Days",
      60 => "60 Days"
    }

  def uri, do: "new_users"
end
