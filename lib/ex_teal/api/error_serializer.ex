defmodule ExTeal.Api.ErrorSerializer do
  @moduledoc """
  Translates a changeset into an error
  """

  alias Ecto.Changeset
  alias ExTeal.Resource.Serializer

  @doc """
  Traverses and translates changeset errors.

  See `Ecto.Changeset.traverse_errors/2`
  """
  def translate_errors(%Changeset{} = changeset) do
    Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts
        |> Keyword.get(String.to_existing_atom(key), key)
        |> to_string()
      end)
    end)
  end

  def render(%Changeset{} = changeset) do
    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.
    errors =
      changeset
      |> translate_errors()
      |> flatten()

    %{
      errors: errors
    }
  end

  def render(data) do
    if Keyword.keyword?(data) do
      data |> Enum.into(%{}) |> Jason.encode!()
    else
      Jason.encode(data)
    end
  end

  def flatten(data) do
    Enum.reduce(data, %{}, &flatten_element/2)
  end

  defp flatten_element({key, value}, acc) when is_map(value) do
    Enum.reduce(value, acc, fn {subkey, subvalue}, acc ->
      Map.put(acc, "#{key}.#{subkey}", subvalue)
    end)
  end

  defp flatten_element({key, value}, acc) do
    Map.put(acc, key, value)
  end

  def handle_error(conn, {:error, %Changeset{} = cs}) do
    body = cs |> render() |> Jason.encode!()
    Serializer.as_json(conn, body, 422)
  end

  def handle_error(conn, :not_authorized) do
    body =
      Jason.encode!(%{
        id: "NOT_AUTHORIZED",
        title: "Not Authorized",
        status: 403
      })

    Serializer.as_json(conn, body, 403)
  end

  def handle_error(conn, _reason) do
    body =
      Jason.encode!(%{
        id: "NOT_FOUND",
        title: "Resource not found",
        status: 404
      })

    Serializer.as_json(conn, body, 404)
  end
end
