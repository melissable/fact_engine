defmodule FactEngine.Repo.Migrations.CreateSeeds do
  use Ecto.Migration
  alias FactEngine.{
    Repo,
    Species
  }

  def up do
    Repo.insert!(%Species{id: 1, name: "Human"})
    Repo.insert!(%Species{id: 2, name: "Cat"})
    Repo.insert!(%Species{id: 3, name: "Frog"})
    Repo.insert!(%Species{id: 4, name: "Toad"})

    IO.puts "added application species"
  end

  def down do
  	execute "delete from species where name in ('Human', 'Cat');"
  end
end
