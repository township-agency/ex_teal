defmodule ExTeal.Api.MetricResponder do
  @moduledoc """
  API Responder for Metrics
  """

  alias ExTeal.Api.ErrorSerializer
  alias ExTeal.Metric.{Request, Result}
  alias ExTeal.Resource.Serializer

  @doc """
  Return the metric based on it's uri for a dashboard
  """
  def get(conn, uri) do
    with {:ok, metric} <- ExTeal.dashboard_metric_for(conn, uri),
         %Request{} = request <- build_request(conn, metric),
         data <- metric.calculate(request),
         result <- build_result(request, metric, data) do
      send_result(conn, result)
    else
      {:error, reason} -> ErrorSerializer.handle_error(conn, reason)
    end
  end

  @doc """
  Return a metric based on it's uri and the resource it's displayed on
  """
  def resource_index(conn, resource_name, uri) do
    with {:ok, resource, metric} <- ExTeal.resource_metric_for(conn, resource_name, uri),
         %Request{} = request <- build_request(conn, metric, resource),
         data <- metric.calculate(request),
         result <- build_result(request, metric, data) do
      send_result(conn, result)
    else
      {:error, reason} -> ErrorSerializer.handle_error(conn, reason)
    end
  end

  @doc """
  Return a metric based on it's uri, resource and resource id
  """
  def resource_detail(conn, resource_name, _resource_id, uri) do
    with {:ok, resource, metric} <- ExTeal.resource_metric_for(conn, resource_name, uri),
         %Request{} = request <- build_request(conn, metric, resource),
         data <- metric.calculate(request),
         result <- build_result(request, metric, data) do
      send_result(conn, result)
    else
      {:error, reason} -> ErrorSerializer.handle_error(conn, reason)
    end
  end

  defp build_request(conn, metric, resource \\ nil), do: Request.from_conn(conn, metric, resource)

  defp build_result(request, metric, data) do
    metric
    |> Result.base_result(request)
    |> Result.put_data(data)
  end

  defp send_result(conn, result) do
    {:ok, body} = Jason.encode(%{metric: result})
    Serializer.as_json(conn, body, 200)
  end
end
