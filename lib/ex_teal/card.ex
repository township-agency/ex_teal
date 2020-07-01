defmodule ExTeal.Card do
  @moduledoc """
  Represents a Card that can be displayed on a dashboard or resource
  """
  alias ExTeal.Card

  @serialized ~w(component only_on_detail options width title)a
  @derive {Jason.Encoder, only: @serialized}

  @type t :: %__MODULE__{}

  defstruct component: nil,
            only_on_detail: false,
            only_on_index: false,
            options: %{},
            width: "1/3",
            title: nil

  @callback component() :: String.t()
  @callback only_on_detail(Plug.Conn.t()) :: bool
  @callback only_on_index(Plug.Conn.t()) :: bool
  @callback options() :: map()
  @callback width() :: String.t()

  defmacro __using__(_opts) do
    quote do
      @behaviour ExTeal.Card
      def component, do: nil
      def only_on_detail(_), do: false
      def only_on_index(_), do: false
      def options, do: %{}
      def width, do: "1/3"
      def title, do: nil
      def uri, do: nil

      defoverridable component: 0,
                     only_on_detail: 1,
                     only_on_index: 1,
                     options: 0,
                     width: 0,
                     title: 0,
                     uri: 0
    end
  end

  def to_struct(module, conn) do
    %Card{
      component: module.component(),
      only_on_detail: module.only_on_detail(conn),
      only_on_index: module.only_on_index(conn),
      options: module.options(),
      width: module.width(),
      title: module.title()
    }
  end
end
