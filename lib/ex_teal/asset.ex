defmodule ExTeal.Asset do
  @moduledoc """
  Functionality for fetching Vue Assets
  """
  defstruct [:styles, :scripts, :compiled_assets]

  def all_assets do
    compiled_assets =
      case Application.fetch_env(:ex_teal, :compiled_assets) do
        {:ok, val} -> val
        :error -> true
      end

    assets_for(compiled_assets)
  end

  defp assets_for(true) do
    manifest =
      :ex_teal
      |> :code.priv_dir()
      |> Path.join(["static/", "teal/", "manifest.json"])
      |> File.read!()
      |> Jason.decode!()

    %__MODULE__{
      compiled_assets: true,
      scripts: scripts_in_manifest(manifest),
      styles: styles_in_manifest(manifest)
    }
  end

  defp assets_for(false) do
    %__MODULE__{
      compiled_assets: false
    }
  end

  defp scripts_in_manifest(map) do
    map
    |> Enum.filter(fn {k, v} ->
      is_not_a_chunk?(k) && is_not_minified?(v) && !is_css?(v)
    end)
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.sort()
  end

  defp styles_in_manifest(map) do
    map
    |> Enum.filter(fn {k, v} ->
      is_not_a_chunk?(k) && is_not_minified?(v) && is_css?(v)
    end)
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.sort()
  end

  defp is_not_a_chunk?("npm." <> _), do: true
  defp is_not_a_chunk?("js/" <> _), do: false
  defp is_not_a_chunk?(_), do: true

  defp is_not_minified?(value) do
    !String.ends_with?(value, ".gz") && !String.ends_with?(value, ".br")
  end

  defp is_css?(value), do: String.ends_with?(value, ".css")
end
