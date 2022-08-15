defmodule FactEngine.Creature do
  use FactEngineWeb, :model
  import Ecto.{Query, Changeset}, warn: false
  alias FactEngine.{Repo, Friend, Species, Creature}

  @timestamps_opts [type: :utc_datetime]

  schema "creatures" do
    field :name, :string
    belongs_to(:species, Species)
    has_many :friends, Friend, on_delete: :delete_all
    timestamps()
  end

  @available_fields ~w(name species_id)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @available_fields, empty_values: [])
    |> foreign_key_constraint(:species)
    |> cast_assoc(:species)
  end

  def save(params) do
    %Creature{}
    |> changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changes -> Repo.insert(changes)
      %Ecto.Changeset{errors: errors} -> errors
      other -> other
    end
  end

  defp projection(query) do
    query
    |> select([b], %{
        id: b.id,
        name: b.name,
        species_id: b.species_id
      })
  end

  def verify_species({value_1, value_2}) do
    params = %{
      "Name" => value_1,
      "Species" => value_2
    }
    Creature
    |> join(:inner, [b], s in assoc(b, :species))
    |> name_filter(params)
    |> species_filter(params)
    |> limit(1)
    |> Repo.one()
  end

  def get_all(params) do
    Creature
    |> join(:inner, [b], s in assoc(b, :species))
    |> name_filter(params)
    |> species_filter(params)
    |> order_by([b, s], b.name)
    |> projection()
    |> Repo.all()
  end

  defp name_filter(query, %{"Name" => name}) do
    query
    |> where([b, s],  like(
      fragment("LOWER(?)", b.name),
      ^"%#{String.downcase(name)}%"
    ))
  end
  defp name_filter(query, _), do: query

  defp species_filter(query, %{"Species" => species_name}) do
    query
    |> where([b, s],  like(
      fragment("LOWER(?)", s.name),
      ^"%#{String.downcase(species_name)}%"
    ))
  end
  defp species_filter(query, _), do: query
end
