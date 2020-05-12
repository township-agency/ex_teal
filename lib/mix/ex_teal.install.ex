defmodule Mix.Tasks.ExTeal.Gen.Install do
  @moduledoc """
    Generates the manifest file and basic folder structure
  """

  use Mix.Task
  alias Mix.ExTeal.Gen.Manifest

  def run(_args) do
    manifest = Manifest.new()
    paths = generator_paths()

    prompt_for_conflicts(manifest)

    manifest
    |> create_folders()
    |> copy_new_files(paths, manifest: manifest)

    if Mix.env() != :test do
      Mix.Shell.cmd("mix format", fn output -> IO.write(output) end)
    end
  end

  defp create_folders(manifest) do
    folders = folders_to_create()

    Enum.each(folders, fn folder ->
      path = manifest.web_path <> "/ex_teal/" <> folder
      Mix.Generator.create_directory(path)
    end)

    manifest
  end

  defp copy_new_files(%Manifest{} = manifest, paths, binding) do
    files = files_to_be_generated(manifest)
    Mix.Phoenix.copy_from(paths, "priv/templates/ex_teal.gen.install/", binding, files)
  end

  defp prompt_for_conflicts(manifest) do
    manifest
    |> files_to_be_generated()
    |> Mix.Phoenix.prompt_for_conflicts()
  end

  defp files_to_be_generated(%Manifest{} = manifest) do
    [{:eex, "manifest.ex", manifest.file}]
  end

  defp folders_to_create do
    ["actions", "resources"]
  end

  defp generator_paths, do: [".", :ex_teal]
end
