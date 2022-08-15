defmodule FactEngineWeb.Router do
  use FactEngineWeb, :router

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FactEngineWeb do
    pipe_through :browser

    get "/", PageController, :index
  end
  
  scope "/api", FactEngineWeb do
    pipe_through :browser
    get "/get_species", PageController, :get_species
    post "/get_creatures", PageController, :get_creatures
    post "/get_friendships", PageController, :get_friendships
    post "/save_creature", PageController, :save_creature
    post "/save_friendships", PageController, :save_friendship
    post "/query_facts", PageController, :query_facts
    post "/process_csv", PageController, :process_csv
  end

  # Other scopes may use custom stacks.
  # scope "/api", FactEngineWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/monitor" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: FactEngineWeb.Telemetry
    end
  end
end
