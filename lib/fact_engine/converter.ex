defmodule FactEngine.Converter do
  require Logger
  import Ecto.Query, warn: false

  def site_url do
    raw_url = FactEngineWeb.Endpoint.url()

    url_segments =
      raw_url
      |> String.split(":")

    case length(url_segments) do
      2 -> Enum.at(url_segments, 0)
      3 -> Enum.at(url_segments, 0) <> ":" <> Enum.at(url_segments, 1)
      # something else we didn't anticipate
      _ -> raw_url
    end
  end

  def force_int(nil), do: nil
  def force_int(""), do: nil
  def force_int(v) when is_binary(v), do: String.to_integer(v)
  def force_int(v), do: v

  def string_keys_to_atoms(list) do
    Enum.map(list, fn row ->
      Map.new(row, fn kv = {k, v} ->
        if is_binary(k) do
          {String.to_atom(k), v}
        else
          kv
        end
      end)
    end)
  end

  def to_x_or_blank(nil), do: nil
  def to_x_or_blank(b) when is_boolean(b), do: if(b, do: "X", else: "")
end
