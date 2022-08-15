defmodule FactEngine.Friend do
  use Ecto.Schema
  import Ecto.{Query, Changeset}, warn: false

  alias FactEngine.{
    Repo, Friend, Creature
  }

  @timestamps_opts [type: :utc_datetime]

  schema "friends" do
    belongs_to(:friend_1, Creature)
    belongs_to(:friend_2, Creature)
    timestamps()
  end
  
  @available_fields ~w(friend_1_id friend_2_id)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @available_fields)
    |> foreign_key_constraint(:friend_1)
    |> cast_assoc(:friend_1)
    |> foreign_key_constraint(:friend_2)
    |> cast_assoc(:friend_2)
  end

  
  def save(params) do
    %Friend{}
    |> changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changes -> Repo.insert(changes)
      %Ecto.Changeset{errors: errors} -> errors
      other -> other
    end
  end

  def verify_friendship({value_1, value_2}) do
    params = %{
      "Friend 1" => value_1,
      "Friend 2" => value_2
    }
    Friend
    |> join(:inner, [f], fr in assoc(f, :friend_1))
    |> join(:inner, [f, fr], fd in assoc(f, :friend_2))
    |> friend_1_filter(params)
    |> friend_2_filter(params)
    |> limit(1)
    |> Repo.one()
  end

  defp projection(query) do
    query
    |> select([b], %{
        id: b.id,
        friend_1_id: b.friend_1_id,
        friend_2_id: b.friend_2_id
      })
  end

  def get_all(params) do
    Friend
    |> join(:inner, [f], fr in assoc(f, :friend_1))
    |> join(:inner, [f, fr], fd in assoc(f, :friend_2))
    |> projection()
    |> Repo.all()
  end
  
  defp friend_1_filter(query, %{"Friend 1" => friend_name}) do
    query
    |> where([f, fr, fd],  like(
      fragment("LOWER(?)", fr.name),
      ^"%#{String.downcase(friend_name)}%"
    ))
  end
  defp friend_1_filter(query, _), do: query
  
  defp friend_2_filter(query, %{"Friend 2" => friend_name}) do
    query
    |> where([f, fr, fd],  like(
      fragment("LOWER(?)", fd.name),
      ^"%#{String.downcase(friend_name)}%"
    ))
  end
  defp friend_2_filter(query, _), do: query
end
