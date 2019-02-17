defmodule SamMediaWeb.OrderController do
  use SamMediaWeb, :controller

  action_fallback(SamMediaWeb.FallbackController)

  alias SamMedia.Order
  alias SamMedia.Order.Projections.Order, as: OrderPro

  def index(conn, _params) do
    orders = Order.list_orders()
    render(conn, "index.json", orders: orders)
  end

  def create(conn, %{
        "order" => order_params
        # %{
        #   "user_name" => user_name,
        #   "user_email" => user_email,
        #   "amount" => amount,
        #   "user_mobile" => user_mobile,
        #   "card_number" => card_number,
        #   "card_expiry" => card_expiry,
        #   "card_security_code" => card_security_code,
        #   "card_holder_name" => card_holder_name
        # } = 
      }) do
    with {:ok, %OrderPro{} = order} <-
           Order.create_order(order_params) do
      conn
      |> put_status(:created)
      |> render("show.json", order: order)
    end
  end
end
