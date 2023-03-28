defmodule ExTeal.Api.ResourceResponder do
  @moduledoc """
  Hands requests of a certain type to the appropriate resource,
  and returns the resources response as serialized json
  """
  alias ExTeal.Api.ErrorSerializer
  alias ExTeal.{FieldFilter, Panel}
  alias ExTeal.Resource.{Create, Delete, Export, Fields, Index, Serializer, Show, Update}

  @spec index(Plug.Conn.t(), binary) :: Plug.Conn.t()
  def index(conn, resource_uri) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri),
         true <- resource.policy().view_any?(conn) do
      Index.call(resource, conn)
    else
      error -> responder_error(conn, error)
    end
  end

  @spec show(Plug.Conn.t(), binary, binary) :: Plug.Conn.t()
  def show(conn, resource_uri, resource_id) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri),
         true <- resource.policy().view_any?(conn) do
      Show.call(resource, conn, resource_id)
    else
      error -> responder_error(conn, error)
    end
  end

  @spec creation_fields(Plug.Conn.t(), binary) :: Plug.Conn.t()
  def creation_fields(conn, resource_uri) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri),
         true <- resource.policy().create_any?(conn) do
      panels = Panel.gather_panels(resource)
      fields = Fields.fields_for(:new, resource)
      schema = resource.model()

      fields =
        fields
        |> Enum.map(fn field ->
          new_schema = struct(schema, %{})
          field.type.apply_options_for(field, new_schema, conn, :new)
        end)
        |> Panel.give_panel_to_fields(resource)

      {:ok, body} = Jason.encode(%{fields: fields, panels: panels})
      Serializer.as_json(conn, body, 200)
    else
      error -> responder_error(conn, error)
    end
  end

  @spec field(Plug.Conn.t(), binary, binary) :: Plug.Conn.t()
  def field(conn, resource_uri, field_name) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri),
         true <- resource.policy().view_any?(conn),
         {:ok, field} <- Fields.field_for(resource, field_name) do
      new_schema = resource.model() |> struct(%{})
      field = field.type.apply_options_for(field, new_schema, conn, :show)
      {:ok, body} = Jason.encode(%{field: field})
      Serializer.as_json(conn, body, 200)
    else
      error -> responder_error(conn, error)
    end
  end

  @spec update_fields(Plug.Conn.t(), binary, binary) :: Plug.Conn.t()
  def update_fields(conn, resource_uri, resource_id) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri),
         model <- resource.handle_show(conn, resource_id),
         true <- resource.policy().update?(conn, model) do
      fields =
        :edit
        |> Fields.fields_for(resource)
        |> Fields.apply_values(model, resource, conn, :edit, nil)
        |> Panel.give_panel_to_fields(resource)

      panels = Panel.gather_panels(resource)

      {:ok, body} = Jason.encode(%{fields: fields, panels: panels})
      Serializer.as_json(conn, body, 200)
    else
      error -> responder_error(conn, error)
    end
  end

  @spec relatable(Plug.Conn.t(), binary, binary) :: Plug.Conn.t()
  def relatable(conn, resource_uri, relationship) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri),
         true <- resource.policy().view_any?(conn),
         {:ok, related_resource} <- ExTeal.resource_for_relationship(resource, relationship) do
      Index.query_for_related(related_resource, conn)
    else
      error -> responder_error(conn, error)
    end
  end

  @spec filters_for(Plug.Conn.t(), binary) :: Plug.Conn.t()
  def filters_for(conn, resource_uri) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri),
         true <- resource.policy().view_any?(conn) do
      filters = resource.filters_for(conn)
      {:ok, body} = Jason.encode(%{filters: filters})
      Serializer.as_json(conn, body, 200)
    else
      error -> responder_error(conn, error)
    end
  end

  @spec actions_for(Plug.Conn.t(), binary) :: Plug.Conn.t()
  def actions_for(conn, resource_uri) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri),
         true <- resource.policy().view_any?(conn) do
      actions = resource.actions_for(conn)
      {:ok, body} = Jason.encode(%{actions: actions})
      Serializer.as_json(conn, body, 200)
    else
      error -> responder_error(conn, error)
    end
  end

  @spec commit_action(Plug.Conn.t(), binary) :: Plug.Conn.t()
  def commit_action(conn, resource_uri) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri),
         true <- resource.policy().view_any?(conn),
         {:ok, resp} <- ExTeal.Action.apply_action(resource, conn) do
      {:ok, body} = Jason.encode(resp)
      Serializer.as_json(conn, body, 200)
    else
      error -> responder_error(conn, error)
    end
  end

  @spec export(Plug.Conn.t(), binary) :: Plug.Conn.t()
  def export(conn, resource_uri) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri),
         true <- resource.policy().view_any?(conn) do
      Export.stream(resource, conn)
    else
      error -> responder_error(conn, error)
    end
  end

  @spec create(Plug.Conn.t(), binary) :: Plug.Conn.t()
  def create(conn, resource_uri) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri),
         true <- resource.policy().create_any?(conn) do
      Create.call(resource, conn)
    else
      error -> responder_error(conn, error)
    end
  end

  @spec update(Plug.Conn.t(), binary, binary) :: Plug.Conn.t()
  def update(conn, resource_uri, resource_id) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri),
         model <- resource.handle_show(conn, resource_id),
         true <- resource.policy().update?(conn, model) do
      Update.call(resource, resource_id, conn)
    else
      error -> responder_error(conn, error)
    end
  end

  @spec delete(Plug.Conn.t(), binary) :: Plug.Conn.t()
  def delete(conn, resource_uri) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri),
         true <- resource.policy().delete_any?(conn) do
      Delete.call(resource, conn)
    else
      error -> responder_error(conn, error)
    end
  end

  @spec reorder(Plug.Conn.t(), binary) :: Plug.Conn.t()
  def reorder(conn, resource_uri) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri),
         true <- resource.policy().update_any?(conn) do
      Update.batch_update(resource, conn)
    else
      error -> responder_error(conn, error)
    end
  end

  @spec field_filters(Plug.Conn.t(), binary) :: Plug.Conn.t()
  def field_filters(conn, resource_uri) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri),
         true <- resource.policy().view_any?(conn) do
      FieldFilter.for_resource(resource, conn)
    else
      error -> responder_error(conn, error)
    end
  end

  defp responder_error(conn, false), do: ErrorSerializer.handle_error(conn, :not_authorized)
  defp responder_error(conn, {:error, reason}), do: ErrorSerializer.handle_error(conn, reason)
end
