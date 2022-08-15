defmodule FactEngine.Love do
  use FactEngineWeb, :model
  import Ecto.{Query, Changeset}, warn: false
  alias FactEngine.{Repo, Love, Creature}

  @timestamps_opts [type: :utc_datetime]

  schema "loves" do
    belongs_to(:creature, Creature)
    field :items, {:array, :integer}
    timestamps()
  end

  @available_fields ~w(creature_id items)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @available_fields, empty_values: [])
  end

  def save(params) do
    %Love{}
    |> Repo.insert()
  end

  defp projection(query) do
    query
    |> select([b], %{
        id: b.id,
        creature_id: b.creature_id,
        items: b.items
      })
  end

  def get_all(params) do
    Love
    |> creature_id_filter(params)
    |> projection()
    |> Repo.all()
  end

  defp creature_id_filter(query, %{"creature_id" => creature_id}) do
    query
    |> where([x], x.creature_id == ^creature_id)
  end
  defp name_filter(query, _), do: query
end
