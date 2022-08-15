defmodule FactEngine.Parser do
  alias NimbleCSV.RFC4180, as: CSV
  
  def process_csv(file, strategy) do
    if is_nil(Map.get(file, :path, nil)) do Map.get(file, "path") else Map.get(file, :path) end
    |> File.stream!()
    |> CSV.parse_enumerable()
    |> Enum.map(fn [first_name, last_name, phone_number, email] ->
      %{first_name: :binary.copy(first_name),
        last_name: :binary.copy(last_name),
        phone: :binary.copy(phone_number),
        email: :binary.copy(email)
      }
    end)
    |> assess_duplicates(strategy)
  end

  defp assess_duplicates(list, strategy) when strategy == "email,phone" do
    strategy
    |> String.split(",")
    |> Enum.map(fn str ->
      assess_duplicates(list, str)
    end)
    |> List.flatten()
    |> Enum.sort_by(fn x -> x.match_key end)
  end
  defp assess_duplicates(list, strategy) do
    match_key = String.to_atom(strategy)
    Enum.group_by(list, fn x -> x[match_key] end)
    |> Enum.filter(fn {_key, list} ->
      if (Enum.count(list) > 1) do true else false end
    end)
    |> Enum.map(fn {key, list} -> 
      %{
        match_key: strategy,
        matched_value: key,
        list: list
      }
    end)
  end
end
