Mix.shell(Mix.Shell.Process)

# mock live reloading for testing the generated application

defmodule Phoenix.LiveReloader do
  def init(opts), do: opts
  def call(conn, _), do: conn
end

defmodule MixHelper do
  import ExUnit.Assertions
  import ExUnit.CaptureIO

  def tmp_path do
    Path.expand("../../tmp", __DIR__)
  end

  def random_string(len) do
    len |> :crypto.strong_rand_bytes() |> Base.encode64() |> binary_part(0, len)
  end

  def in_tmp(which, function) do
    path = Path.join([tmp_path(), random_string(10), to_string(which)])

    try do
      File.rm_rf!(path)
      File.mkdir_p!(path)
      File.cd!(path, function)
    after
      File.rm_rf!(path)
    end
  end

  def in_tmp_project(which, function) do
    conf_before = Application.get_env(:phoenix, :generators) || []
    path = Path.join([tmp_path(), random_string(10), to_string(which)])

    try do
      apps_path = Path.join(path, "apps")
      config_path = Path.join(path, "config")
      File.rm_rf!(path)
      File.mkdir_p!(path)
      File.mkdir_p!(apps_path)
      File.mkdir_p!(config_path)
      File.touch!(Path.join(path, "mix.exs"))

      for file <- ~w(config.exs dev.exs test.exs prod.exs) do
        File.write!(Path.join(config_path, file), "use Mix.Config\n")
      end

      File.cd!(apps_path, function)
    after
      Application.put_env(:phoenix, :generators, conf_before)
      File.rm_rf!(path)
    end
  end

  def in_project(app, path, fun) do
    %{name: name, file: file} = Mix.Project.pop()

    try do
      capture_io(:stderr, fn ->
        Mix.Project.in_project(app, path, [], fun)
      end)
    after
      Mix.Project.push(name, file)
    end
  end

  def assert_file(file) do
    assert File.regular?(file), "Expected #{file} to exist, but it does not"
  end

  def refute_file(file) do
    refute File.regular?(file), "Expected #{file} not to exist, but it does"
  end

  def assert_file(file, match) do
    cond do
      is_list(match) ->
        assert_file(file, &Enum.each(match, fn m -> assert &1 =~ m end))

      is_binary(match) or Regex.regex?(match) ->
        assert_file(file, &assert(&1 =~ match))

      is_function(match, 1) ->
        assert_file(file)
        match.(File.read!(file))

      true ->
        raise inspect({file, match})
    end
  end

  def with_generator_env(new_env, fun) do
    Application.put_env(:phoenix, :generators, new_env)

    try do
      fun.()
    after
      Application.delete_env(:phoenix, :generators)
    end
  end

  def umbrella_mixfile_contents do
    """
    defmodule Umbrella.MixProject do
      use Mix.Project
      def project do
        [
          apps_path: "apps",
          deps: deps()
        ]
      end
      defp deps do
        []
      end
    end
    """
  end

  def flush do
    receive do
      _ -> flush()
    after
      0 -> :ok
    end
  end
end
