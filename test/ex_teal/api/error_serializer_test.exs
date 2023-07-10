defmodule ExTeal.Api.ErrorSerializerTest do
  use ExUnit.Case, async: true
  alias Ecto.Changeset

  alias ExTeal.Api.ErrorSerializer

  test "flatten/1 returns a flattened map" do
    assert ErrorSerializer.flatten(%{foo: %{bar: "baz"}}) == %{"foo.bar" => "baz"}
    assert ErrorSerializer.flatten(%{foo: %{bar: ["baz"]}}) == %{"foo.bar" => ["baz"]}
  end

  test "translate_errors/1" do
    data = %{}
    types = %{name: :string}
    params = %{name: nil}

    changeset =
      {data, types}
      |> Changeset.cast(params, Map.keys(types))
      |> Changeset.validate_required(Map.keys(types))

    assert ErrorSerializer.translate_errors(changeset) == %{name: ["can't be blank"]}
  end
end
