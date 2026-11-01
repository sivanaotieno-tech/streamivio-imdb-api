defmodule StreamivioImdbApi.Router do
  use Phoenix.Router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", StreamivioImdbApi do
    pipe_through :api

    get "/ping", ApiController, :ping
    get "/search", ApiController, :search
    get "/:tconst", ApiController, :show
  end
end
