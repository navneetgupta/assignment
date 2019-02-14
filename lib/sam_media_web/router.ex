defmodule SamMediaWeb.Router do
  use SamMediaWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(Plug.RequestId)
  end

  scope "/api", SamMediaWeb do
    pipe_through :api

    get("/orders", OrderController, :index)
  end
end
