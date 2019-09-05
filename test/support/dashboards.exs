defmodule TestExTeal.MainDashboard do
  use ExTeal.Dashboard

  def cards(_conn), do: [TestExTeal.NewUsersMetric]
end
