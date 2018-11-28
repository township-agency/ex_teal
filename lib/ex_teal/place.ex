defmodule ExTeal.Place do
  @moduledoc """
  The core struct that represents and validates an address
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset
  alias ExTeal.Place

  @serialized ~w(company address address_line_2 city state zip country)a
  @derive {Jason.Encoder, only: @serialized}

  @type t :: %__MODULE__{}

  embedded_schema do
    field(:company, :string)
    field(:address, :string)
    field(:address_line_2, :string)
    field(:city, :string)
    field(:state, :string)
    field(:zip, :string)
    field(:country, :string)
  end

  @fields ~w(address city state zip country address_line_2 company)

  @required_fields ~w(address city state zip country)a

  @spec changeset(Place.t(), map()) :: Changeset.t()
  def changeset(address, params) do
    address
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
