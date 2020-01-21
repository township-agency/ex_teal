defmodule ExTeal.Api.ResourceResponder do
  @moduledoc """
  Hands requests of a certain type to the appropriate resource,
  and returns the resources response as serialized json
  """
  alias ExTeal.Api.ErrorSerializer
  alias ExTeal.Resource.{Create, Delete, Fields, Index, Serializer, Show, Update}

  def index(conn, resource_uri) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri) do
      Index.call(resource, conn)
    else
      {:error, reason} -> ErrorSerializer.handle_error(conn, reason)
    end
  end

  def show(conn, resource_uri, resource_id) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri) do
      Show.call(resource, conn, resource_id)
    else
      {:error, reason} -> ErrorSerializer.handle_error(conn, reason)
    end
  end

  def creation_fields(conn, resource_uri) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri) do
      fields = Fields.fields_for(:new, resource)
      schema = resource.model()

      fields =
        Enum.map(fields, fn field ->
          new_schema = struct(schema, %{})
          field.type.apply_options_for(field, new_schema, :new)
        end)

      {:ok, body} = Jason.encode(%{fields: fields})
      Serializer.as_json(conn, body, 200)
    end
  end

  def field(conn, resource_uri, field_name) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri),
         {:ok, field} <- Fields.field_for(resource, field_name) do
      new_schema = resource.model() |> struct(%{})
      field = field.type.apply_options_for(field, new_schema, :show)
      {:ok, body} = Jason.encode(%{field: field})
      Serializer.as_json(conn, body, 200)
    else
      {:error, reason} -> ErrorSerializer.handle_error(conn, reason)
    end
  end

  def update_fields(conn, resource_uri, resource_id) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri) do
      model = resource.handle_show(conn, resource_id)

      fields =
        :edit
        |> Fields.fields_for(resource)
        |> Fields.apply_values(model, resource, :edit, nil)

      {:ok, body} = Jason.encode(%{fields: fields})
      Serializer.as_json(conn, body, 200)
    end
  end

  def relatable(conn, resource_uri, relationship) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri),
         {:ok, related_resource} <- ExTeal.resource_for_relationship(resource, relationship) do
      Index.query_for_related(related_resource, conn)
    else
      {:error, reason} -> ErrorSerializer.handle_error(conn, reason)
    end
  end

  def filters_for(conn, resource_uri) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri) do
      filters = resource.filters_for(conn)
      {:ok, body} = Jason.encode(%{filters: filters})
      Serializer.as_json(conn, body, 200)
    else
      {:error, reason} -> ErrorSerializer.handle_error(conn, reason)
    end
  end

  def actions_for(conn, resource_uri) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri) do
      actions = resource.actions_for(conn)
      {:ok, body} = Jason.encode(%{actions: actions})
      Serializer.as_json(conn, body, 200)
    else
      {:error, reason} -> ErrorSerializer.handle_error(conn, reason)
    end
  end

  def commit_action(conn, resource_uri) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri),
         {:ok, resp} <- ExTeal.Action.apply_action(resource, conn) do
      {:ok, body} = Jason.encode(resp)
      Serializer.as_json(conn, body, 200)
    else
      {:error, reason} ->
        ErrorSerializer.handle_error(conn, reason)
    end
  end

  def create(conn, resource_uri) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri) do
      Create.call(resource, conn)
    end
  end

  def update(conn, resource_uri, resource_id) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri) do
      Update.call(resource, resource_id, conn)
    end
  end

  def delete(conn, resource_uri) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri) do
      Delete.call(resource, conn)
    else
      {:error, reason} -> ErrorSerializer.handle_error(conn, reason)
    end
  end

  def reorder(conn, resource_uri) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri) do
      Update.batch_update(resource, conn)
    end
  end
end
