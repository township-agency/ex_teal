defmodule ExTeal.Resource.Repo do
  @doc """
  Defines the module `use`-ing `Ecto.Repo` to be used by the resource.

  Defaults to the value set in config if present:

      config :ex_teal,
         repo: MyApp.Repo

  Default can be overridden per resource:

      def repo, do: MyApp.SecondaryRepo

  """
  @callback repo() :: module
  defmacro __using__(_opts) do
    quote do
      unless ExTeal.Resource.Repo in @behaviour do
        @behaviour ExTeal.Resource.Repo
        unquote(default_repo())
      end
    end
  end

  @doc false
  def default_repo do
    quote do
      def repo, do: Application.fetch_env!(:ex_teal, :repo)
      defoverridable repo: 0
    end
  end
end
