defmodule ExTeal.Resource.Serializer do
  @moduledoc """
  Serializes a resource response into json
  """

  import Plug.Conn

  alias ExTeal.Api.ErrorSerializer

  def send(conn, :index, body) do
    {:ok, encoded} = Jason.encode(body)
    as_json(conn, encoded)
  end

  def error(conn, :not_found) do
    {:ok, body} =
      Jason.encode(%{
        errors: %{
          "detail" => "The resource was not found",
          "status" => 404,
          "title" => "Not Found"
        }
      })

    as_json(conn, body, 404)
  end

  def render_index(
        %{
          results: models,
          all: all,
          total: total
        },
        resource,
        conn
      ) do
    meta = resource.meta_for(:index, models, all, total, resource, conn)

    policy = resource.policy()
    filtered_models = Enum.filter(models, &policy.view?(conn, &1))
    data = resource.serialize_response(:index, resource, filtered_models, conn)

    {:ok, response} =
      Jason.encode(%{
        meta: meta,
        data: data
      })

    as_json(conn, response)
  end

  def render_related(models, resource, conn) do
    data = Enum.map(models, &schema_summary(&1, resource))
    {:ok, response} = Jason.encode(%{data: data})
    as_json(conn, response)
  end

  @doc """
  Generates a map that summarizes the specified schema
  for global and relational searches.
  """
  def schema_summary(schema, resource) do
    %{
      id: schema.id,
      title: resource.title_for_schema(schema),
      subtitle: resource.subtitle_for_schema(schema),
      thumbnail: resource.thumbnail_for_schema(schema)
    }
  end

  def render_show(model, resource, conn) do
    case resource.policy().view?(conn, model) do
      false ->
        ErrorSerializer.handle_error(conn, :not_authorized)

      true ->
        data = resource.serialize_response(:show, resource, model, conn)
        {:ok, response} = Jason.encode(data)
        as_json(conn, response)
    end
  end

  def render_create(model, resource, conn) do
    data = resource.serialize_response(:show, resource, model, conn)
    {:ok, response} = Jason.encode(data)
    as_json(conn, response, 201)
  end

  def render_update(model, resource, conn) do
    data = resource.serialize_response(:show, resource, model, conn)
    {:ok, response} = Jason.encode(data)
    as_json(conn, response, 200)
  end

  def render_errors(conn, errors) do
    {:ok, body} = errors |> ErrorSerializer.render() |> Jason.encode()
    as_json(conn, body, 422)
  end

  def as_json(conn, body, status \\ 200) do
    conn
    |> put_resp_content_type("text/json")
    |> resp(status, body)
    |> send_resp()
  end
end
