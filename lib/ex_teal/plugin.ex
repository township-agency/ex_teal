defmodule ExTeal.Plugin do
  @moduledoc """
  The base module that describes the functionality of a plugin
  """

  alias ExTeal.Asset.Script
  alias ExTeal.Plugin

  @serialized ~w(uri title navigation_component)a
  @derive {Jason.Encoder, only: @serialized}

  @type t :: %__MODULE__{}

  defstruct uri: nil,
            title: nil,
            navigation_component: nil,
            options: nil,
            router: nil,
            scripts: [],
            styles: []

  defmacro __using__(_opts) do
    quote do
      use ExTeal.Resource.Repo

      alias ExTeal.{Naming, Plugin}

      def uri, do: nil
      def navigation_component, do: nil
      def title, do: Naming.resource_name(__MODULE__)
      def router, do: nil

      def scripts, do: []
      def styles, do: []

      def new(opts) do
        params = %{
          title: __MODULE__.title(),
          uri: __MODULE__.uri(),
          navigation_component: __MODULE__.navigation_component(),
          options: opts,
          router: __MODULE__.router(),
          scripts: __MODULE__.scripts(),
          styles: __MODULE__.styles()
        }

        struct(Plugin, params)
      end

      defoverridable(uri: 0, navigation_component: 0, title: 0, router: 0, scripts: 0, styles: 0)
    end
  end

  def available_scripts(%Plugin{uri: uri, scripts: scripts}) do
    Enum.map(scripts, fn %Script{} = script ->
      Map.put(script, :plugin_uri, uri)
    end)
  end
end
