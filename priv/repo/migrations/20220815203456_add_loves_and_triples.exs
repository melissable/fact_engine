defmodule FactEngine.Repo.Migrations.AddLovesAndTriples do
  use Ecto.Migration

  def change do
    create table(:loves, primary_key: false) do
      add :id, :serial, primary_key: true
      add :creature_id, references(:creatures, type: :integer, on_delete: :delete_all), null: false
      add :items, {:array, :string}
      timestamps(type: :timestamptz)
    end
    
    create table(:triples, primary_key: false) do
      add :id, :serial, primary_key: true
      add :int_tuple, {:array, :integer}
      timestamps(type: :timestamptz)
    end
  end
end
