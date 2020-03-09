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
    Changeset.traverse_errors(changeset, &parse_changeset_error/1)
  end

  defp parse_changeset_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  defp parse_changeset_error(msg), do: msg

  def render(%Changeset{} = changeset) do
    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.

    %{
      errors: translate_errors(changeset)
    }
  end

  def render(data) do
    if Keyword.keyword?(data) do
      data |> Enum.into(%{}) |> Jason.encode!()
    else
      Jason.encode(data)
    end
  end

  def handle_error(conn, {:error, %Changeset{} = cs}) do
    body = cs |> render() |> Jason.encode!()
    Serializer.as_json(conn, body, 422)
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
