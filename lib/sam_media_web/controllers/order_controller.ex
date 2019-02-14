defmodule SamMediaWeb.OrderController do
  use SamMediaWeb, :controller

  action_fallback(SamMediaWeb.FallbackController)

  def index(conn, _params) do
    render(conn, "index.json",
      orders: [
        # %{uuid: "qwerzddfesdfercxcsd", amount: 11201.12, items: [], description: "description"}
      ]
    )
  end
end
