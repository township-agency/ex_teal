defmodule ExTeal do
  @moduledoc false
  alias ExTeal.Plugin
  alias Plug.Conn

  @type record :: map() | Ecto.Schema.t()
  @type records :: module | Ecto.Query.t() | list(record)

  @spec application_name() :: String.t()
  def application_name do
    case manifest() do
      nil -> "ExTeal"
      module -> module.application_name()
    end
  end

  @spec logo_image_path() :: String.t()
  def logo_image_path do
    case manifest() do
      nil -> "/assets/static/images/logo.svg"
      module -> module.logo_image_path()
    end
  end

  @spec path() :: String.t()
  def path do
    case manifest() do
      nil -> "/teal"
      module -> module.path()
    end
  end

  @spec json_configuration(Plug.Conn.t()) :: map()
  def json_configuration(conn) do
    case manifest() do
      nil -> %{}
      module -> module.json_configuration(conn)
    end
  end

  @spec available_resources() :: [ExTeal.Resource.t()]
  def available_resources do
    case manifest() do
      nil -> []
      module -> module.resources()
    end
  end

  @spec available_dashboards(Plug.Conn.t()) :: [module()]
  def available_dashboards(conn) do
    case manifest() do
      nil -> []
      module -> Enum.filter(module.dashboards(), & &1.display?(conn))
    end
  end

  @spec available_nav_groups(Plug.Conn.t()) :: [String.t()]
  def available_nav_groups(conn) do
    case manifest() do
      nil -> []
      module -> module.nav_groups(conn)
    end
  end

  @spec dashboard_for(Plug.Conn.t(), String.t()) :: {:ok, module()} | {:error, :not_found}
  def dashboard_for(conn, uri) do
    case Enum.find(available_dashboards(conn), fn x -> x.uri() == uri end) do
      nil -> {:error, :not_found}
      module -> {:ok, module}
    end
  end

  @spec dashboard_metric_for(Conn.t(), String.t()) :: {:ok, module} | {:error, :not_found}
  def dashboard_metric_for(conn, uri) do
    all_metrics =
      available_dashboards(conn)
      |> Enum.map(& &1.cards(conn))
      |> Enum.concat()

    case Enum.find(all_metrics, &(&1.uri() == uri)) do
      nil -> {:error, :not_found}
      module -> {:ok, module}
    end
  end

  @spec resource_metric_for(Conn.t(), String.t(), String.t()) ::
          {:ok, module, module} | {:error, :not_found}
  def resource_metric_for(conn, resource_name, metric_uri) do
    with {:ok, resource} <- resource_for(resource_name),
         cards <- resource.cards(conn),
         metric when not is_nil(metric) <- Enum.find(cards, &(&1.uri() == metric_uri)) do
      {:ok, resource, metric}
    else
      _ -> {:error, :not_found}
    end
  end

  def auth_provider do
    case manifest() do
      nil -> []
      module -> module.auth_provider()
    end
  end

  def default_policy do
    case manifest() do
      nil -> ExTeal.OpenEverywherePolicy
      module -> module.default_policy()
    end
  end

  @spec resource_for(String.t()) :: {:ok, ExTeal.Resource.t()} | {:error, :not_found}
  def resource_for(name) do
    case Enum.find(available_resources(), fn x -> x.uri() == name end) do
      nil -> {:error, :not_found}
      module -> {:ok, module}
    end
  end

  @spec resource_for_field(ExTeal.Field.t()) :: {:ok, ExTeal.Resource.t()} | {:error, :not_found}
  def resource_for_field(field) do
    case Enum.find(available_resources(), fn x -> x.title() == Inflex.pluralize(field.name) end) do
      nil -> {:error, :not_found}
      module -> {:ok, module}
    end
  end

  @spec resource_for_model(module) :: {:ok, ExTeal.Resource.t()} | {:error, :not_found}
  def resource_for_model(model) do
    case Enum.find(available_resources(), &(&1.model() == model)) do
      nil -> {:error, :not_found}
      module -> {:ok, module}
    end
  end

  @spec searchable_resources() :: [module]
  def searchable_resources do
    Enum.filter(available_resources(), fn x -> not Enum.empty?(x.search()) end)
  end

  @spec available_plugins() :: [ExTeal.Plugin.t()]
  def available_plugins do
    case manifest() do
      nil -> []
      module -> module.plugins()
    end
  end

  @spec plugin_for(String.t()) :: {:ok, ExTeal.Plugin.t()} | {:error, :not_found}
  def plugin_for(name) do
    case Enum.find(available_plugins(), fn x -> x.uri() == name end) do
      nil -> {:error, :not_found}
      module -> {:ok, module}
    end
  end

  @spec all_scripts() :: [ExTeal.Asset.Script.t()]
  def all_scripts do
    available_plugins()
    |> Enum.map(&Plugin.available_scripts/1)
    |> List.flatten()
  end

  @spec resource_for_relationship(ExTeal.Resource.t(), String.t()) ::
          {:ok, ExTeal.Resource.t()} | {:error, :not_found}
  def resource_for_relationship(resource, relationship) do
    rel = String.to_existing_atom(relationship)
    assoc = resource.model().__schema__(:association, rel)

    case resource_for_model(assoc.queryable) do
      {:ok, module} -> {:ok, module}
      {:error, :not_found} -> {:error, :not_found}
    end
  end

  @spec theme() :: ExTeal.Theme.t()
  def theme do
    case manifest() do
      nil -> %ExTeal.Theme{}
      module -> module.theme()
    end
  end

  def manifest do
    Application.fetch_env!(:ex_teal, :manifest)
  end
end
