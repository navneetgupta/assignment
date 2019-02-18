defmodule SamMediaWeb.OrderController do
  use SamMediaWeb, :controller
  use PhoenixSwagger

  action_fallback(SamMediaWeb.FallbackController)

  alias SamMedia.Order
  alias SamMedia.Order.Projections.Order, as: OrderPro

  swagger_path :list_order do
    get("/api/orders")
    summary("list all Orders")
    description("list all Orders")
    response(200, "Ok", %{})
  end

  def list_order(conn, _params) do
    orders = Order.list_orders()
    render(conn, "index.json", orders: orders)
  end

  swagger_path :create_order do
    post("/api/orders")
    summary("Create An Order")
    description("Create An Order")

    parameters do
      tracker(
        :body,
        %Schema{
          type: :object,
          example: %{
            order: %{
              user_name: "Navneet Kumar",
              user_email: "user_email",
              amount: 100,
              user_mobile: "0556364603",
              card_number: "1234123412341234",
              card_expiry: "11/21",
              card_security_code: "123",
              card_holder_name: "Navneet Kumar"
            }
          }
        },
        "Create An Order",
        required: true
      )
    end

    response(200, "Ok", %{})
  end

  def create_order(conn, %{
        "order" => order_params
      }) do
    with {:ok, %OrderPro{} = order} <-
           Order.create_order(order_params) do
      conn
      |> put_status(:created)
      |> render("show.json", order: order)
    end
  end

  swagger_path :get_order do
    get("/api/orders/{order_uuid}")
    summary("Get Order Details")
    description("Get Order Details")

    parameters do
      order_uuid(:path, :string, "Order UUID", required: true)
    end

    response(200, "Ok", %{})
  end

  def get_order(conn, %{
        "id" => order_uuid
      }) do
    order = Order.get_order!(order_uuid)
    render(conn, "show.json", order: order)
  end

  swagger_path :cancel_order do
    delete("/api/orders/{order_uuid}")
    summary("Cancel a Order")
    description("Cancel a Order")

    parameters do
      order_uuid(:path, :string, "Order UUID", required: true)
    end

    response(204, "Ok", %{})
  end

  def cancel_order(conn, %{
        "id" => order_uuid
      }) do
    with {:ok} <- Order.cancel_order(order_uuid) do
      conn
      |> send_resp(:no_content, "")
    end
  end
end
