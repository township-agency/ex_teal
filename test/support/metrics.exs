defmodule TestExTeal.NewUsersMetric do
  use ExTeal.Metric.Value

  @impl true
  def calculate(request) do
    count(request, TestExTeal.User)
  end

  @impl true
  def uri, do: "new_users"
end

defmodule TestExTeal.NewUserTrend do
  use ExTeal.Metric.Trend

  @impl true
  def calculate(request) do
    count(request, TestExTeal.User)
  end
end

defmodule TestExTeal.PostFeaturedTrend do
  use ExTeal.Metric.Trend
  @impl true
  def calculate(request) do
    count(request, TestExTeal.Post)
  end

  @impl true
  def date_field, do: :featured_on

  @impl true
  def date_field_type, do: :date
end

defmodule TestExTeal.RevenueTrend do
  use ExTeal.Metric.Trend

  @impl true
  def calculate(request) do
    [
      %{label: "Total", data: sum(request, TestExTeal.Order, :grand_total)},
      %{label: "Count", data: count(request, TestExTeal.Order)}
    ]
  end

  @impl true
  def multiple_results, do: true

  @impl true
  def prefix, do: "$"
end
