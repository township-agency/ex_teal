defmodule Mix.ExTeal.Gen.Manifest do
  @moduledoc false

  alias Mix.ExTeal.Gen.Manifest

  defstruct context_app: nil,
            base: nil,
            web_path: nil,
            web_namespace: nil,
            module: nil,
            ex_teal_context: nil,
            humanized_name: nil,
            file: nil

  def new do
    ctx_app = Mix.Phoenix.context_app()
    web_path = Mix.Phoenix.web_path(ctx_app)
    file = web_path <> "/ex_teal" <> "/manifest.ex"
    base = Mix.Phoenix.context_base(ctx_app)
    web_namespace = base <> "Web"
    module = web_namespace <> ".ExTeal.Manifest"
    ex_teal_context = web_namespace <> ".ExTeal"
    humanized_name = Phoenix.Naming.humanize(ctx_app)

    %Manifest{
      base: base,
      context_app: ctx_app,
      file: file,
      web_path: web_path,
      web_namespace: web_namespace,
      module: module,
      ex_teal_context: ex_teal_context,
      humanized_name: humanized_name
    }
  end
end
