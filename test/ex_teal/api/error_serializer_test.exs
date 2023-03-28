defmodule ExTeal.Api.ErrorSerializerTest do
  use ExUnit.Case, async: true

  alias ExTeal.Api.ErrorSerializer

  test "flatten/1 returns a flattened map" do
    assert ErrorSerializer.flatten(%{foo: %{bar: "baz"}}) == %{"foo.bar" => "baz"}
    assert ErrorSerializer.flatten(%{foo: %{bar: ["baz"]}}) == %{"foo.bar" => ["baz"]}
  end
end
