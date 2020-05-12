defmodule Mix.Tasks.ExTeal.Gen.Resource do
  use Mix.Task
  alias Mix.ExTeal.Gen.Resource

  @moduledoc """
  Generates an ex_teal resource
  """

  @switches []

  def run(args) do
    resource = build(args)

    if File.exists?(resource.manifest_path) do
      paths = generator_paths()

      prompt_for_conflicts(resource)

      resource
      |> copy_new_files(paths, resource: resource)
      |> maybe_inject_into_manifest()

      if Mix.env() != :test do
        Mix.Shell.cmd("mix format", fn output -> IO.write(output) end)
      end
    else
      raise_with_help(
        "Expected to find a manifest.ex file, please run 'mix ex_teal.gen.install before generating a resource."
      )
    end
  end

  @doc false
  def build(args) do
    {_, parsed, _} = OptionParser.parse(args, switches: @switches)
    [resource_name | attrs] = validate_args!(parsed)

    Resource.new(resource_name, attrs)
  end

  defp maybe_inject_into_manifest(
         %Resource{ctx_app: ctx_app, web_module_alias: module} = resource
       ) do
    web_prefix = Mix.Phoenix.web_path(ctx_app)
    file_path = Path.join(web_prefix, "ex_teal/manifest.ex")
    file = File.read!(file_path)
    resource_module = String.split(module, ".") |> List.last()

    if String.contains?(file, resource_module) do
      :ok
    else
      do_inject_resource(file, file_path, resource_module, resource)
    end

    resource
  end

  defp do_inject_resource(file, file_path, resource_module, resource) do
    [new_file, alias_inject] = inject_alias_into_manifest(file, resource, resource_module)
    [new_file, resource_inject] = inject_resource_into_manifest(new_file, resource_module)

    if file != new_file do
      File.write!(file_path, new_file)
    else
      Mix.shell().info("""
        Add your #{inspect(resource_module)} alias to #{file_path}:
          defmodule #{inspect(resource.web_module_alias)}.Manifest do
            #{alias_inject}

            #{resource_inject}
            ...
          end
      """)
    end
  end

  def inject_alias_into_manifest(file, resource, resource_module) do
    [regex, alias_inject] =
      cond do
        empty_alias_line?(file, resource) ->
          replace_regex = ~r/alias #{resource.base}Web.ExTeal.\{\}/
          alias_inject = "alias #{resource.base}Web.ExTeal.\{#{resource_module}\}"
          [replace_regex, alias_inject]

        has_multiline_alias?(file, resource) ->
          regex_for_parse = ~r/alias #{resource.base}Web.ExTeal.\{[^}]*/
          alias_inject = run_regex_and_parse(file, resource_module, regex_for_parse)

          replace_regex = ~r/alias #{resource.base}Web.ExTeal.\{\n[[A-Za-z,\s\n]*/
          [replace_regex, alias_inject]

        true ->
          alias_inject = singleline_alias_for_inject(resource, resource_module, file)
          regex = ~r/alias #{resource.base}Web.ExTeal.\{[A-Za-z,\s\n]*/
          [regex, alias_inject]
      end

    new_file = Regex.replace(regex, file, alias_inject)
    [new_file, alias_inject]
  end

  def inject_resource_into_manifest(file, resource_module) do
    [regex, resource_inject] =
      cond do
        empty_resource_line?(file) ->
          replace_regex = ~r/def resources, do: \[\]/
          resource_inject = "def resources, do: [#{resource_module}]"
          [replace_regex, resource_inject]

        has_multiline_resource_block?(file) ->
          resource_inject = multiline_resource_inject(resource_module, file)
          replace_regex = ~r/def resources,\n    do: \[[A-Za-z,\s\n]*/s
          [replace_regex, resource_inject]

        true ->
          resource_inject = singleline_resource_inject(resource_module, file)

          regex = ~r/def resources, do: \[[^\]]*/
          [regex, resource_inject]
      end

    new_file = Regex.replace(regex, file, resource_inject)
    [new_file, resource_inject]
  end

  def has_multiline_alias?(file, resource),
    do: String.match?(file, ~r/alias #{resource.base}Web.ExTeal.\{\n/)

  def has_multiline_resource_block?(file),
    do: String.match?(file, ~r/def resources,\n    do: \[[^\]]*/)

  def empty_resource_line?(file),
    do: String.match?(file, ~r/def resources, do: \[\]/)

  def empty_alias_line?(file, resource),
    do: String.match?(file, ~r/alias #{resource.base}Web.ExTeal.\{\}/)

  def singleline_alias_for_inject(resource, resource_module, file) do
    inject = run_regex_and_parse(file, resource_module, ~r/(?<=\{).+?(?=\})/)

    "alias #{resource.base}Web.ExTeal.\{#{inject}"
  end

  def singleline_resource_inject(resource_module, file) do
    regex = ~r/def resources, do: \[[^\]]*/
    inject = run_regex_and_parse(file, resource_module, regex)
    inject
  end

  def multiline_resource_inject(resource_module, file) do
    inject = run_regex_and_parse(file, resource_module, ~r/(?<=\[).+?(?=\])/s)

    "def resources,    do: \[#{inject}"
  end

  defp run_regex_and_parse(file, resource_module, regex) do
    regex
    |> Regex.run(file)
    |> parse_inject(resource_module)
  end

  defp parse_inject(["Endpoint.url()"], resource_module), do: resource_module

  defp parse_inject([inject_line], resource_module) do
    inject_line
    |> String.replace("\n", "")
    |> String.split(",")
    |> Enum.concat([resource_module])
    |> Enum.join(",")
  end

  defp prompt_for_conflicts(resource) do
    resource
    |> files_to_be_generated()
    |> Mix.Phoenix.prompt_for_conflicts()
  end

  @doc false
  defp validate_args!([resource | _] = args) do
    if Resource.valid?(resource) do
      args
    else
      raise_with_help(
        "Expected the resource argument, #{inspect(resource)}, to be a valid module name"
      )
    end
  end

  defp validate_args!(_) do
    raise_with_help("Invalid arguments")
  end

  defp copy_new_files(%Resource{} = resource, paths, binding) do
    files = files_to_be_generated(resource)
    Mix.Phoenix.copy_from(paths, "priv/templates/ex_teal.gen/", binding, files)

    resource
  end

  defp files_to_be_generated(%Resource{} = resource) do
    [{:eex, "resource.ex", resource.file}]
  end

  defp generator_paths, do: [".", :ex_teal]

  @doc false
  @spec raise_with_help(String.t()) :: no_return()
  def raise_with_help(msg) do
    Mix.raise("""
    #{msg}

      mix ex_teal.gen.resource expects the module name in camelCase format,
      for proper aliasing include contexts,

      for example:

        mix ex_teal.gen.resource User

      with a context:

        mix ex_teal.gen.resource Accounts.User
    """)
  end
end
