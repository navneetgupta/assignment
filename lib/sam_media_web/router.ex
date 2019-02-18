defmodule SamMediaWeb.Router do
  use SamMediaWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(Plug.RequestId)
  end

  scope "/api", SamMediaWeb do
    pipe_through :api

    get("/orders", OrderController, :list_order)
    post("/orders", OrderController, :create_order)
    delete("/orders/:id", OrderController, :cancel_order)
    get("/orders/:id", OrderController, :get_order)
  end

  scope "/swagger" do
    forward("/", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :sam_media,
      swagger_file: "swagger.json",
      disable_validator: true
    )
  end

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "sam_media"
      }
    }
  end
end
