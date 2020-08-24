defmodule ExTeal.Fields.BooleanGroup do
  @moduledoc """
  A group of boolean inputs that represent a map, or embedded schema
  where each value is a boolean.  Useful for embedding features, permissions,
  or roles into a schema.

  If the field represents and embedded schema as an `embeds_one`, the field
  will set a default set of options based on the fields of the embedded schema.
  It assumes that every field in the embed is a boolean:

      defmodule Permissions do
        use Ecto.Schema

        embedded_schema do
          field :read, :boolean, default: false
          field :write, :boolean, default: false
          field :delete, :boolean, default: false
        end

        def changeset(permissions, attrs) do
          cast(permission, attrs, [:read, :write, :delete])
        end
      end

      defmodule Post do
        use Ecto.Schema

        schema "posts" do
          field :title, :string
          embeds_one :permissions, Permissions
        end
      end


      def PostResource do
        use ExTeal.Resource
        def model, do: Post

        def fields, do: [
          Text.make(:title),
          BooleanGroup.make(:permissions)
        ]
      end

  You can also define a boolean group over a plain map type and manually
  define the options as a map of keys and labels:

      defmodule Post do
        use Ecto.Schema

        schema "posts" do
          field :title, :string
          field :permissions, :map
        end
      end

      def PostResource do
        use ExTeal.Resource
        def model, do: Post

        def fields, do: [
          Text.make(:title),
          BooleanGroup.make(:permissions)
          |> BooleanGroup.options(%{
            "read" => "Read",
            "write" => "Write"
          })
        ]
      end

  The `options` function can also be used to override the default options
  when used with an embedded schema if the options need to be translated into
  human readable values.
  """

  use ExTeal.Field
  alias ExTeal.Field

  def component, do: "boolean-group"

  @impl true
  def default_sortable, do: false

  @impl true
  def apply_options_for(field, model, _type) do
    schema = model.__struct__

    case schema.__schema__(:type, field.field) do
      :map ->
        field

      {:embed, embedded} ->
        fields = embedded.related.__schema__(:fields)

        opts =
          (fields -- [:id])
          |> Enum.into(%{}, fn f ->
            field_string = Atom.to_string(f)
            {field_string, field_string}
          end)

        options(field, opts)
    end
  end

  @impl true
  def sanitize_as, do: :json

  @doc """
  Add the available options to manage in the boolean group
  """
  @spec options(Field.t(), map()) :: Field.t()
  def options(field, options) do
    opts = Map.merge(options, %{group_options: options})
    %{field | options: opts}
  end

  @doc """
  Customize the text displayed in the event that a field contains no values.
  """
  @spec no_value_text(Field.t(), String.t()) :: Field.t()
  def no_value_text(field, text) do
    %{field | options: Map.put(field.options, :no_value, text)}
  end
end
