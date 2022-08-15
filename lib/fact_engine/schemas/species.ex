defmodule FactEngine.Species do
  use Ecto.Schema
  import Ecto.Query
  alias FactEngine.{Repo}

  @primary_key {:id, :integer, []}
  @derive {Phoenix.Param, key: :id}

  @human_id 1
  @cat_id 2

  @human_name "Human"
  @cat_name "Cat"

  schema "species" do
    field :name, :string
  end

  def human(), do: @human_id
  def cat(), do: @cat_id

  def human_name(), do: @human_name
  def cat_name(), do: @cat_name

  defp base_query do
    (from r in FactEngine.Species)
  end

  def get_all(params) do
    query_builder(params)
    |> Repo.all()
  end

  def query_builder(params) do
    base_query()
    |> id_filter(params)
    |> name_filter(params)
    |> IO.inspect(label: "0000000000000000000")
    |> projection()
    |> IO.inspect(label: "11111111111111111")
  end

  defp projection(query) do
    select(query, [b], %{
      value: b.id,
      label: b.name
    })
  end

  defp id_filter(query, %{"id" => id}) do
    query
    |> where([x], x.id == ^id)
  end
  defp id_filter(query, _), do: query

  defp name_filter(query, %{"name" => name}) do
    query
    |> where([x], x.name == ^name)
  end
  defp name_filter(query, _), do: query
end