use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :fact_engine, FactEngine.Repo,
  username: "postgres",
  password: "postgres",
  database: "fact_engine_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :fact_engine, FactEngineWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

if File.exists?("#{Path.dirname(__ENV__.file)}/local.exs") do
  import_config "local.exs"
end