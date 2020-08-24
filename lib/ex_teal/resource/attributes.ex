defmodule ExTeal.Resource.Attributes do
  @moduledoc """
  Provides the `permitted_attributes/3` callback used for filtering attributes.

  This behaviour is used by the following ExTeal.Resource actions:

    * ExTeal.Resource.Delete
    * ExTeal.Resource.Create
  """

  alias ExTeal.Field
  alias ExTeal.Panel

  @doc """
  Used to determine which attributes are permitted during create and update.

  The attributes map (the second argument) is a "flattened" version including
  the values at `data/attributes`, `data/type` and any relationship values in
  `data/relationships/[name]/data/id` as `name_id`.

  The third argument is the atom of the action being called.

  Example:

      defmodule MyApp.V1.PostResource do
        use ExTeal.Resource

        def permitted_attributes(conn, attrs, :create) do
          attrs
          |> Map.take(~w(title body type category_id))
          |> Map.merge("author_id", conn.assigns[:current_user])
        end

        def permitted_attributes(_conn, attrs, :update) do
          Map.take(attrs, ~w(title body type category_id))
        end
      end

  """
  @callback permitted_attributes(Plug.Conn.t(), ExTeal.Resource.attributes(), :update | :create) ::
              ExTeal.Resource.attributes()

  defmacro __using__(_) do
    quote do
      alias ExTeal.Resource.Attributes

      unless Attributes in @behaviour do
        @behaviour Attributes

        def permitted_attributes(_conn, attrs, _) do
          fields =
            __MODULE__.fields()
            |> Enum.map(fn
              %Field{} = f -> [f]
              %Panel{fields: fields} -> fields
            end)
            |> Enum.concat()
            |> Enum.into(%{}, fn %Field{field: field} = f -> {field, f} end)

          field_keys =
            fields
            |> Map.keys()
            |> Enum.map(&Atom.to_string/1)

          skip_sanitize = __MODULE__.skip_sanitize()
          Attributes.maybe_sanitize(attrs, fields, skip_sanitize)
        end

        def parse(param) do
        end

        defoverridable permitted_attributes: 3, parse: 1
      end
    end
  end

  @spec maybe_sanitize(map(), map(), boolean()) :: map()
  def maybe_sanitize(attrs, _fields, true) do
    attrs
    |> Enum.reject(fn {k, _v} -> is_nil(k) end)
    |> Enum.into(%{})
  end

  def maybe_sanitize(attrs, fields, _) do
    attrs
    |> Enum.map(&sanitize_param(&1, fields))
    |> Enum.reject(fn {k, _v} -> is_nil(k) end)
    |> Enum.into(%{})
  end

  @doc false
  def from_params(params), do: params

  def sanitize_param({k, "null"}, _), do: {k, nil}

  def sanitize_param({k, ""}, _), do: {k, nil}

  def sanitize_param({k, val}, _) when not is_bitstring(val), do: {k, val}

  def sanitize_param({"_" <> _, _val}, _), do: {nil, nil}

  def sanitize_param({k, v}, fields) do
    if String.ends_with?(k, "_id") do
      {k, v}
    else
      field = Map.get(fields, String.to_existing_atom(k))

      case field do
        nil -> {nil, nil}
        %Field{} = f -> {k, sanitize(f.sanitize, v)}
      end
    end
  end

  @valid_sanitizers ~w(noscrub basic_html html5 markdown_html strip_tags)a
  def sanitize(false, value), do: value

  def sanitize(:json, value) do
    Jason.decode!(value)
  end

  def sanitize(key, value) when is_atom(key) and key in @valid_sanitizers do
    apply(HtmlSanitizeEx, key, [value])
  end

  def sanitize_as(field, :skip) do
    %{field | sanitize: false}
  end

  def sanitize_as(field, sanitizer) when sanitizer in @valid_sanitizers do
    %{field | sanitize: sanitizer}
  end

  def raw_html(field), do: %{field | sanitize: false}
end
