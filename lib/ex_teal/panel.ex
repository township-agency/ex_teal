defmodule ExTeal.Panel do
  @moduledoc """
  Separates fields on the detail page into panels
  """
  alias ExTeal.Field
  alias ExTeal.Resource.Fields

  @derive {Jason.Encoder, except: [:fields, :field]}
  defstruct name: nil, key: nil, fields: [], options: %{}, field: nil
  @type t :: %__MODULE__{}

  @type options :: %{
          optional(:helper_text) => String.t(),
          optional(:limit) => non_neg_integer(),
          optional(:apply_to_all) => map()
        }

  @doc """
  Creates a new panel
  """
  @spec new(String.t(), [Field.t()], options()) :: t()
  def new(name, fields, options \\ %{}) do
    key = panel_key(name)

    fields =
      Enum.map(fields, fn field ->
        field
        |> Map.put(:panel, key)
        |> Map.merge(Map.get(options, :apply_to_all, %{}))
      end)

    %__MODULE__{
      name: name,
      key: key,
      fields: fields,
      options: options
    }
  end

  @doc """
  Add helper text for the panel
  """
  @spec helper_text(t, String.t()) :: t
  def helper_text(panel, text) do
    %{panel | options: Map.put(panel.options, :helper_text, text)}
  end

  @doc """
  Limit the amount of fields that show by default on the detail page
  Other fields are hidden behind a "Show more" button
  """
  @spec limit(t, integer) :: t
  def limit(panel, limit) do
    %{panel | options: Map.put(panel.options, :limit, limit)}
  end

  @doc """
  Given a resource, uses the fields definition to find the panels
  """
  def gather_panels(resource) do
    fields = Fields.all_fields(resource)
    user_defined = Enum.filter(fields, &is_a_panel?/1)
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
    "#{resource.singular_title()} Details"
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
