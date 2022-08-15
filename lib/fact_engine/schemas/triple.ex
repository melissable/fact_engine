defmodule FactEngine.Triple do
  use FactEngineWeb, :model
  import Ecto.{Query, Changeset}, warn: false
  alias FactEngine.{Repo, Friend, Species, Triple}

  @timestamps_opts [type: :utc_datetime]

  schema "triples" do
    field :int_tuple, {:array, :integer}
    timestamps()
  end

  @available_fields ~w(int_tuple)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @available_fields, empty_values: [])
  end

  def save(params) do
    %Triple{}
    |> changeset(params)
    |> Repo.insert()
  end

  def get_all(params) do
    Triple
    |> Repo.all()
  end
end
