defmodule ExTeal.Api.MetricResponder do
  @moduledoc """
  API Responder for Metrics
  """

  alias ExTeal.Api.ErrorSerializer
  alias ExTeal.Metric.Request
  alias ExTeal.Resource.Serializer

  @doc """
  Return the metric based on it's uri for a dashboard
  """
  def get(conn, uri) do
    with {:ok, metric_module} <- ExTeal.dashboard_metric_for(conn, uri),
         %Request{} = request <- metric_module.request(conn),
         {:ok, result} <- metric_module.calculate(request) do
      {:ok, body} = Jason.encode(%{metric: result})
      Serializer.as_json(conn, body, 200)
    else
      {:error, reason} -> ErrorSerializer.handle_error(conn, reason)
    end
  end

  @doc """
  Return a metric based on it's uri and the resource it's displayed on
  """
  def resource_index(conn, resource_name, uri) do
    with {:ok, resource, metric} <- ExTeal.resource_metric_for(conn, resource_name, uri),
         %Request{} = request <- metric.request(conn, resource),
         {:ok, result} <- metric.calculate(request) do
      {:ok, body} = Jason.encode(%{metric: result})
      Serializer.as_json(conn, body, 200)
    else
      {:error, reason} -> ErrorSerializer.handle_error(conn, reason)
    end
  end

  @doc """
  Return a metric based on it's uri, resource and resource id
  """
  def resource_detail(conn, resource_name, _resource_id, uri) do
    with {:ok, resource, metric} <- ExTeal.resource_metric_for(conn, resource_name, uri),
         %Request{} = request <- metric.request(conn, resource),
         {:ok, result} <- metric.calculate(request) do
      {:ok, body} = Jason.encode(%{metric: result})
      Serializer.as_json(conn, body, 200)
    else
      {:error, reason} -> ErrorSerializer.handle_error(conn, reason)
    end
  end
end
