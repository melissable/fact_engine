defmodule FactEngineWeb.PageController do
  use FactEngineWeb, :controller
  
  alias FactEngine.{
    Parser,
    Species,
    Creature,
    Friend
  }

  @failure_result %{
    success: false
  }

  @success_result %{
    success: true
  }
  
  @species "species"
  @friends "friends"

  def index(conn, params) do
    case params do
      %{} ->
        render(conn, "index.html")
      non_empty_params ->
          non_empty_params
          |> Map.get("path")
          |> Enum.at(-1)
        render(conn, "index.html")
    end
  end
    
  def get_species(conn, params) do
    json(conn, Species.get_all(params))
  end
    
  def get_creatures(conn, params) do
    json(conn, Creature.get_all(params))
  end
    
  def get_friendships(conn, params) do
    json(conn, Friend.get_all(params))
  end
    
  def save_creature(conn, params) do
    Creature.save(params)
    |> parse_result(conn)
  end
    
  def save_friendship(conn, params) do
    Friend.save(params)
    |> parse_result(conn)
  end

  def query_facts(conn, %{ "queryType" => query_type, "inputs" => input_values}) do
    input_values = Enum.map(input_values, fn v -> String.downcase(v) end)
    values = {Enum.at(input_values, 0), Enum.at(input_values, 1)}
    case query_type do
      @species ->
        json(conn, %{
            success: true,
            match: if is_nil(Creature.verify_species(values)) do false else true end
          })
      @friends ->
        json(conn, %{
            success: true,
            match:  if is_nil(Friend.verify_friendship(values)) do false else true end
          })
      _ -> 
        json(conn, %{
          success: false,
          message: "Unknown query type"
        })
    end
  end

  def parse_result({:ok, _result}, conn), do: json(conn, @success_result)
  def parse_result({:error, error}, conn), do: json(conn, Map.put(@failure_result, :error, error))
  def parse_result(error, conn) do
    json(conn, @failure_result)
  end
end
