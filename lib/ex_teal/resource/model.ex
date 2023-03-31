defmodule ExTeal.Resource.Model do
  @moduledoc """
  Provides the `model/0` callback used to customize the resource served.

  This behaviour is used by all ExTeal actions.
  """

  alias Phoenix.Naming

  @doc """
  Must return the module implementing `Ecto.Schema` to be represented.

  Example:

      def model, do: MyApp.Models.Post

  Defaults to the name of the resource, for example the resource
  `MyApp.V1.PostResource` would serve the `MyApp.Post` model.

  Used by the default implementations for `handle_create/2`, `handle_update/3`,
  and `records/1`.
  """
  @callback model() :: module

  @doc """
  Returns the title to display in the side bar.

  Defaults to finding the title from the resource modules name
  """
  @callback title() :: String.t()

  @doc """
  Returns the singularized version of the title to display on forms.
  """
  @callback singular_title() :: String.t()

  @doc """
  Returns the uri to display in the side bar.

  Defaults to finding the uri from the resource modules name
  """
  @callback uri() :: String.t()

  @doc """
  Returns the title to display in relationships.

  Defaults to looking for name or title fields,
  falls back to the schemas name appended by it's id
  """
  @callback title_for_schema(struct) :: String.t() | nil

  @doc """
  Returns the subtitle to display in relationships.

  Defaults to looking for name or title fields,
  falls back to the schemas name appended by it's id
  """
  @callback subtitle_for_schema(struct) :: String.t() | nil

  @doc """
  Returns the thumbnail to display in search.

  Defaults to looking for name or title fields,
  falls back to the schemas name appended by it's id
  """
  @callback thumbnail_for_schema(struct) :: String.t() | nil

  @doc """
  The fields that should be searched
  """
  @callback search() :: [atom()]

  @doc """
  Array of default field filters to be used
  when there are no filters present
  """
  @callback default_filters() :: [map()] | nil

  defmacro __using__(_) do
    quote do
      @behaviour ExTeal.Resource.Model

      alias ExTeal.Resource.Model
      alias Phoenix.Naming

      @inferred_model Model.model_from_resource(__MODULE__)
      @inferred_title Model.title_from_resource(__MODULE__)
      @inferred_uri Model.uri_from_resource(__MODULE__)

      def model, do: @inferred_model
      def title, do: @inferred_title

      def singular_title,
        do: title() |> Inflex.underscore() |> Naming.humanize() |> Inflex.singularize()

      def uri, do: @inferred_uri
      def title_for_schema(schema), do: Model.title_for_schema_from_struct(schema)
      def subtitle_for_schema(schema), do: nil
      def thumbnail_for_schema(schema), do: nil

      def search, do: []

      def default_filters, do: nil

      defoverridable model: 0,
                     title: 0,
                     singular_title: 0,
                     uri: 0,
                     title_for_schema: 1,
                     subtitle_for_schema: 1,
                     thumbnail_for_schema: 1,
                     search: 0,
                     default_filters: 0
    end
  end

  def model_from_resource(module) do
    [_elixir, app | rest] =
      module
      |> Atom.to_string()
      |> String.split(".")

    [resource | _] = Enum.reverse(rest)
    inferred = String.replace(resource, "Resource", "")

    String.to_atom("Elixir.#{app}.#{inferred}")
  end

  def title_from_resource(module) do
    module
    |> Naming.resource_name("Resource")
    |> Naming.humanize()
    |> Inflex.pluralize()
  end

  def uri_from_resource(module) do
    module
    |> title_from_resource()
    |> String.downcase()
    |> String.replace(" ", "_")
  end

  @name_fields ~w(title name)a
  def title_for_schema_from_struct(nil), do: nil

  def title_for_schema_from_struct(struct) do
    values =
      @name_fields
      |> Enum.map(&Map.get(struct, &1))
      |> Enum.reject(fn x -> is_nil(x) end)

    case values do
      [] ->
        title = title_from_resource(struct.__struct__)
        "#{title} #{struct.id}"

      list ->
        List.first(list)
    end
  end
end
