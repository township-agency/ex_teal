defmodule ExTeal.Panel do
  @moduledoc """
  Separates fields on the detail page into panels
  """
  alias ExTeal.Field

  @derive {Jason.Encoder, except: [:fields, :opts, :field]}
  defstruct name: nil, key: nil, fields: [], opts: %{}, field: nil

  @doc """
  Creates a new panel
  """
  def new(name, fields, opts \\ %{}) do
    key = panel_key(name)

    fields =
      Enum.map(fields, fn field ->
        field
        |> Map.put(:panel, key)
        |> Map.merge(Map.get(opts, :apply_to_all, %{}))
      end)

    %__MODULE__{
      name: name,
      key: key,
      fields: fields,
      opts: opts
    }
  end

  @doc """
  Given a resource, uses the fields definition to find the panels
  """
  def gather_panels(resource) do
    user_defined = Enum.filter(resource.fields(), &is_a_panel?/1)
    default = default_panel_for(resource)
    [default] ++ user_defined
  end

  @doc """
  Given a list of fields and a list of panels, assigns the panel to each field
  """
  @spec give_panel_to_fields([Field.t()], module()) :: [Field.t()]
  def give_panel_to_fields(fields, resource) do
    default_panel_key = resource |> default_panel_name() |> panel_key()

    Enum.map(fields, fn field ->
      Map.put(field, :panel, field.panel || default_panel_key)
    end)
  end

  defp is_a_panel?(%__MODULE__{}), do: true
  defp is_a_panel?(_), do: false

  def default_panel_name(resource) do
    title = resource.title() |> String.capitalize() |> Inflex.singularize()
    "#{title} Details"
  end

  defp default_panel_for(resource) do
    name = default_panel_name(resource)

    %__MODULE__{
      name: name,
      key: panel_key(name)
    }
  end

  defp panel_key(name), do: name |> Inflex.underscore() |> String.to_atom()
end
