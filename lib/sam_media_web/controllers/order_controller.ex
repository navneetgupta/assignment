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
      }) do
    with {:ok, %OrderPro{} = order} <-
           Order.create_order(order_params) do
      conn
      |> put_status(:created)
      |> render("show.json", order: order)
    end
  end

  def get(conn, %{
        "id" => order_uuid
      }) do
    order = Order.get_order!(order_uuid)
    render(conn, "show.json", order: order)
  end
end
