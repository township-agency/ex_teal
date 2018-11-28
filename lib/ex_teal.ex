defmodule ExTeal do
  @moduledoc false
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

  @spec json_configuration() :: map()
  def json_configuration do
    case manifest() do
      nil -> %{}
      module -> module.json_configuration()
    end
  end

  @spec available_resources() :: [ExTeal.Resource.t()]
  def available_resources do
    case manifest() do
      nil -> []
      module -> module.resources()
    end
  end

  def auth_provider do
    case manifest() do
      nil -> []
      module -> module.auth_provider()
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

  def manifest do
    Application.get_env(:ex_teal, :manifest)
  end
end
