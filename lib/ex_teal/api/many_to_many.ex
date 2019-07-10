defmodule ExTeal.Api.ManyToMany do
  @moduledoc """
  API Responder that manages the many to many relationships via:

  - `GET attachable` - Querying the potentially related
  - `POST attach` - Adding a related resource
  - `DELETE detach` - Removing a related resource
  - `GET creation-pivot-fields` - Fetch the pivot fields associated with a relationship
  """

  alias Ecto.Changeset
  alias ExTeal.Api.ErrorSerializer
  alias ExTeal.Field
  alias ExTeal.Resource.{Fields, Serializer}

  @doc """
  Given a request of `GET /api/resource_uri/resource_id/attachable/field_name`
  This function returns a response that contains the attachable schemas associated with the many to many relationship at `field_name`
  """
  def attachable(conn, resource_uri, resource_id, field_name) do
    with {:ok, _resource, _model, field} <- attached(conn, resource_uri, resource_id, field_name),
         {:ok, related_resource} <- related_for(field) do
      related_resource.model()
      |> related_resource.repo().all()
      |> Serializer.render_related_key_values(related_resource, conn)
    else
      {:error, :not_found} = resp -> ErrorSerializer.handle_error(conn, resp)
    end
  end

  @doc """
  Given a request of `POST /api/posts/1/attach/tags`
  that contains a set of params like:

      %{
        "viaRelationship" => "tags",
        "tags" => "2"
      }

  This function attaches the tag with id 2 to the posts tags relationship.
  """
  def attach(conn, resource_uri, resource_id, field_name) do
    with {:ok, resource, model, field} <- attached(conn, resource_uri, resource_id, field_name),
         {:ok, _result} <-
           attach_via(
             field.private_options.rel.join_through,
             conn,
             resource,
             model,
             field,
             field_name
           ) do
      {:ok, body} = Jason.encode(%{attached: true})
      Serializer.as_json(conn, body, 201)
    else
      resp -> ErrorSerializer.handle_error(conn, resp)
    end
  end

  defp attach_via(joined, conn, resource, model, field, field_name) when is_bitstring(joined) do
    with {:ok, related_resource} <- related_for(field),
         {:ok, related_id} <- Map.fetch(conn.params, field_name) do
      referenced_field = field.private_options.rel.field
      model = resource.repo().preload(model, referenced_field)
      result = related_resource.handle_show(conn, related_id)
      new_content = Map.get(model, referenced_field) ++ [result]

      model
      |> Changeset.cast(%{}, [])
      |> Changeset.put_assoc(field.private_options.rel.field, new_content)
      |> resource.repo().update()
    else
      :error -> {:error, :not_found}
      {:error, reason} -> {:error, reason}
    end
  end

  defp attach_via(module, conn, resource, model, field, field_name) do
    with {:ok, related_id} <- Map.fetch(conn.params, field_name) do
      [{inner, _}, {outer, _}] = field.private_options.rel.join_keys

      params =
        Map.merge(
          conn.params,
          Enum.into([{Atom.to_string(inner), model.id}, {Atom.to_string(outer), related_id}], %{})
        )

      module
      |> struct()
      |> module.changeset(params)
      |> resource.repo().insert()
    end
  end

  @doc """
  Given a request of `DELETE /api/posts/1/attach/tags/2`
  that contains a set of params like:

  This function detaches the tag with id 2 from the posts tags relationship.
  """
  def detach(conn, resource_uri, resource_id, field_name) do
    with {:ok, resource, model, field} <- attached(conn, resource_uri, resource_id, field_name),
         {:ok, related_resource} <- related_for(field) do
      referenced_field = field.private_options.rel.field
      model = resource.repo().preload(model, referenced_field)
      field_id = conn.params |> Map.get("resources")
      result = related_resource.handle_show(conn, field_id)

      current_ids = model |> Map.get(referenced_field) |> Enum.map(& &1.id)

      if Enum.member?(current_ids, result.id) do
        new_content =
          model
          |> Map.get(referenced_field)
          |> Enum.reject(fn existing -> existing.id == result.id end)

        {:ok, _} =
          model
          |> Changeset.cast(%{}, [])
          |> Changeset.put_assoc(referenced_field, new_content)
          |> resource.repo().update()

        {:ok, body} = Jason.encode(%{detached: true})
        Serializer.as_json(conn, body, 204)
      else
        ErrorSerializer.handle_error(conn, {:error, :not_found})
      end
    else
      {:error, :not_found} = resp -> ErrorSerializer.handle_error(conn, resp)
    end
  end

  @doc """
  Returns a list of fields associated with the pivot table of a many to many
  relationship.  Fields are only for attaching to a many to many
  """
  def creation_pivot_fields(conn, resource_uri, field_name) do
    with {:ok, resource, field} <- resource_and_field(resource_uri, field_name) do
      updated_field = field.type.apply_options_for(field, struct(resource.model()))

      pivot_fields =
        updated_field.private_options
        |> Map.get(:pivot_fields, [])
        |> Enum.filter(& &1.show_on_new)

      {:ok, body} = Jason.encode(%{fields: pivot_fields})
      Serializer.as_json(conn, body, 200)
    else
      {:error, :not_found} = resp -> ErrorSerializer.handle_error(conn, resp)
    end
  end

  defp resource_and_field(resource_uri, field_name) do
    with {:ok, resource} <- ExTeal.resource_for(resource_uri),
         {:ok, found_field} <- Fields.field_for(resource, field_name) do
      {:ok, resource, found_field}
    else
      _ -> {:error, :not_found}
    end
  end

  defp attached(conn, resource_uri, resource_id, field_name) do
    with {:ok, resource, field} <- resource_and_field(resource_uri, field_name),
         model when not is_nil(model) <- resource.handle_show(conn, resource_id),
         %Field{} = updated_field <- field.type.apply_options_for(field, model) do
      {:ok, resource, model, updated_field}
    else
      _ -> {:error, :not_found}
    end
  end

  defp related_for(field) do
    ExTeal.resource_for_model(field.private_options.rel.queryable)
  end
end
