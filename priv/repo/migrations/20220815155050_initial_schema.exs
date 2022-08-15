defmodule FactEngine.Repo.Migrations.InitialSchema do
  use Ecto.Migration

  def change do
    create table(:species, primary_key: false) do
      add :id, :integer, primary_key: true
      add :name, :string, size: 100, null: false
    end

    create table(:creatures, primary_key: false) do
      add :id, :serial, primary_key: true
      add :name, :string, size: 100, null: false
      add :species_id, references(:species, type: :integer, on_delete: :delete_all), null: false
      timestamps(type: :timestamptz)
    end
    
    create table(:friends, primary_key: false) do
      add :id, :serial, primary_key: true
      add :friend_1_id, references(:creatures, type: :integer, on_delete: :delete_all), null: false
      add :friend_2_id, references(:creatures, type: :integer, on_delete: :delete_all), null: false
      timestamps(type: :timestamptz)
    end
  end
end
