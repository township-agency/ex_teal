defmodule ExTeal.Resource.Attributes do
  @moduledoc """
  Provides the `permitted_attributes/3` callback used for filtering attributes.

  This behaviour is used by the following ExTeal.Resource actions:

    * ExTeal.Resource.Delete
    * ExTeal.Resource.Create
  """

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
      unless ExTeal.Resource.Attributes in @behaviour do
        @behaviour ExTeal.Resource.Attributes

        def permitted_attributes(_conn, attrs, _), do: attrs

        defoverridable permitted_attributes: 3
      end
    end
  end

  @doc false
  def from_params(%{"data" => data}), do: data
end
