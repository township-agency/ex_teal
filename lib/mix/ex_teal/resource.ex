defmodule Mix.ExTeal.Gen.Resource do
  @moduledoc """
    Generates an exteal resource and fields
  """

  alias Mix.ExTeal.Gen.Resource
  alias Phoenix.Naming

  defstruct model: nil,
            file: nil,
            title: nil,
            web_module_alias: nil,
            base: nil,
            ctx_app: nil,
            module_alias: nil,
            types: nil,
            fields: nil,
            assocs: nil,
            assocs_by_context: nil,
            manifest_path: nil,
            search_fields: nil

  @default_search_fields [
    :text,
    :text_area,
    :number
  ]

  @valid_types [
    :array,
    :belongs_to,
    :boolean,
    :color,
    :date,
    :date_time,
    :has_many,
    :has_one,
    :ID,
    :integer,
    :many_to_many,
    :many_to_many_belongs_to,
    :multi_select,
    :number,
    :password,
    :place,
    :rich_text,
    :select,
    :text,
    :text_area,
    :toggle
  ]
  @valid_assoc_types [
    :belongs_to,
    :has_many,
    :has_one,
    :many_to_many,
    :many_to_many_belongs_to
  ]

  def valid_types, do: @valid_types

  def valid?(resource) do
    resource =~ ~r/^[A-Z]\w*(\.[A-Z]\w*)*$/
  end

  def new(resource_name, cli_attrs) do
    ctx_app = Mix.Phoenix.context_app()
    inflections = Mix.Phoenix.inflect(resource_name)

    file = resource_file_path(ctx_app, inflections[:singular])
    web_module_alias = web_module_alias(inflections)
    module = inflections[:module]
    {assocs, attrs} = partition_attrs_and_assocs(attrs(cli_attrs))
    assocs_by_context = assocs_by_context(assocs)
    search_fields = default_search_fields(attrs)

    types = attrs |> types()

    all_teal_fields = fields(format_types(types) ++ format_assoc_types(assocs))

    %Resource{
      ctx_app: ctx_app,
      base: inflections[:base],
      model: inflections[:alias],
      file: file,
      title: inflections[:human],
      module_alias: module,
      web_module_alias: web_module_alias,
      types: types,
      fields: all_teal_fields,
      assocs: assocs,
      assocs_by_context: assocs_by_context,
      manifest_path: Mix.Phoenix.web_path(ctx_app) <> "/ex_teal/manifest.ex",
      search_fields: search_fields
    }
  end

  defp default_search_fields(attrs) do
    attrs
    |> Enum.group_by(fn {_k, v} -> v end, fn {k, _v} ->
      k
    end)
    |> Map.take(@default_search_fields)
    |> Map.values()
    |> List.flatten()
  end

  defp assocs_by_context([]), do: nil

  defp assocs_by_context(assocs) do
    case assocs do
      {_flag, _key, _type} ->
        assocs
        |> Enum.group_by(fn {_f, _k, _t} -> "" end, fn {_f, module, _t} -> module end)

      _ ->
        assocs
        |> Enum.group_by(fn {_k, _m, _t, context} -> context end, fn {_k, module, _t, _c} ->
          module
        end)
    end
  end

  defp fields(types), do: types |> Enum.sort() |> Enum.join(", ")

  defp format_types(types) do
    types
    |> Enum.map(fn {_k, v} -> v end)
  end

  defp format_assoc_types(assocs) do
    Enum.map(assocs, fn
      {_k, _v, type, _c} -> type
      {_k, _v, type} -> type
    end)
  end

  defp partition_attrs_and_assocs(attrs) do
    {assocs, attrs} =
      Enum.split_with(attrs, fn
        {:assoc, key, assoc_type} ->
          if Enum.member?(@valid_assoc_types, assoc_type) do
            true
          else
            Mix.raise("""
            ExTeal generator expects the assoc to be given to assoc:#{key}.
            For example:
                mix ex_teal.gen.resource Comment comments assoc:post:belongs_to
            """)
          end

        {:assoc, key, _, _, assoc_type} ->
          if Enum.member?(@valid_assoc_types, assoc_type) do
            true
          else
            Mix.raise("""
            ExTeal generator expects the assoc to be given to assoc:#{key}.
            For example:
                mix ex_teal.gen.resource Comment comments assoc:post:belongs_to:context:content
            """)
          end

        _ ->
          false
      end)

    assocs =
      Enum.map(assocs, fn
        {_flag, key, :context, type, context} ->
          {key, Phoenix.Naming.camelize(Atom.to_string(key)),
           Phoenix.Naming.camelize(Atom.to_string(context)),
           Phoenix.Naming.camelize(Atom.to_string(type))}

        {_flag, key, type} ->
          {key, Phoenix.Naming.camelize(Atom.to_string(key)),
           Phoenix.Naming.camelize(Atom.to_string(type))}
      end)

    {assocs, attrs}
  end

  @doc """
  Parses the attrs as received by generators.
  """
  def attrs(attrs) do
    ["id:ID" | attrs]
    |> Enum.map(fn attr ->
      attr
      |> String.split(":", parts: 5)
      |> list_to_attr()
      |> validate_attr!()
    end)
  end

  defp list_to_attr([key]), do: {String.to_atom(key), :text}
  defp list_to_attr([key, value]), do: {String.to_atom(key), String.to_atom(value)}

  defp list_to_attr([assoc_flag, assoc, type]),
    do: {String.to_atom(assoc_flag), String.to_atom(assoc), String.to_atom(type)}

  defp list_to_attr([assoc_flag, assoc, type, context_flag, context]),
    do:
      {String.to_atom(assoc_flag), String.to_atom(assoc), String.to_atom(context_flag),
       String.to_atom(context), String.to_atom(type)}

  defp types(attrs) do
    Enum.into(attrs, %{}, fn
      {key, val} ->
        {key, Naming.camelize(Atom.to_string(val))}

      {assoc, context, type} ->
        {assoc, context, type}
    end)
  end

  defp web_module_alias(
         alias: aliased,
         human: _,
         base: _,
         web_module: web_module,
         module: _,
         scoped: _,
         singular: _,
         path: _
       ) do
    web_module <> ".ExTeal." <> aliased <> "Resource"
  end

  defp resource_file_path(ctx_app, singular) do
    ctx_app
    |> Mix.Phoenix.web_path()
    |> Kernel.<>("/ex_teal/resources/#{singular}_resource.ex")
  end

  defp validate_attr!({_name, type} = attr) when type in @valid_types, do: attr
  defp validate_attr!({_name, {type, _}} = attr) when type in @valid_types, do: attr

  defp validate_attr!({_assoc_flag, _assoc, type} = attr)
       when type in @valid_assoc_types,
       do: attr

  defp validate_attr!({_assoc_flag, _assoc, _context_flag, _context, type} = attr)
       when type in @valid_assoc_types,
       do: attr

  defp validate_attr!({_, type}) do
    Mix.raise(
      "Unknown type `#{inspect(type)}` given to generator. " <>
        "The supported types are: #{@valid_types |> Enum.sort() |> Enum.join(", ")}"
    )
  end
end
