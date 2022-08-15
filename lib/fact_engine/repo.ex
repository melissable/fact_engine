defmodule FactEngine.Repo do
  use Ecto.Repo,
    otp_app: :fact_engine,
    adapter: Ecto.Adapters.Postgres
end
