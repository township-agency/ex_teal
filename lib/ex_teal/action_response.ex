defmodule ExTeal.ActionResponse do
  @moduledoc """
  Used to return the result of an action
  and specifies how the ux should respond
  """

  @serialized ~w(message url type path)a
  @derive {Jason.Encoder, only: @serialized}

  defstruct [:message, :url, :type, :path]

  alias __MODULE__

  @type t :: %__MODULE__{}

  @doc """
  Display a custom 'success' message.
  """
  @spec success(String.t()) :: ActionResponse.t()
  def success(message), do: %ActionResponse{type: "success", message: message}

  @doc """
  Display a custom 'error' message.
  """
  @spec error(String.t()) :: ActionResponse.t()
  def error(message), do: %ActionResponse{type: "error", message: message}

  @doc """
  Redirect the user to a url
  """
  @spec redirect(String.t()) :: ActionResponse.t()
  def redirect(url), do: %ActionResponse{type: "redirect", url: url}

  @doc """
  Push the user to a new location in the vue app.
  """
  @spec push(String.t()) :: ActionResponse.t()
  def push(path), do: %ActionResponse{type: "push", path: path}

  @doc """
  Download a file at a specific url
  """
  @spec download(String.t()) :: ActionResponse.t()
  def download(url), do: %ActionResponse{type: "download", url: url}
end
