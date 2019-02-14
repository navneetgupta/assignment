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
      items: order.items,
      description: order.description
    }
  end
end
