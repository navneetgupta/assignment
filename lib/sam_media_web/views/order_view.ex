defmodule SamMediaWeb.OrderView do
  use SamMediaWeb, :view
  alias SamMediaWeb.OrderView

  def render("index.json", %{orders: orders}) do
    %{data: render_many(orders, OrderView, "order.json")}
  end

  def render("show.json", %{order: order}) do
    %{data: render_one(order, OrderView, "order.json")}
  end

  def render("order.json", %{order: order}) do
    %{
      id: order.uuid,
      amount: order.amount,
      inserted_at: order.inserted_at,
      updated_at: order.updated_at,
      payment_status: order.payment_status,
      user_mobile: order.user_mobile,
      user_name: order.user_name,
      status: order.status
    }
  end
end
