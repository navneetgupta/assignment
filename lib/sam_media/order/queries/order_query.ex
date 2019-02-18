defmodule SamMedia.Order.Queries.OrderQuery do
  import Ecto.Query
  alias SamMedia.Order.Projections.Order, as: OrderPro

  def get_order(order_id) do
    from(b in OrderPro,
      where: b.uuid == ^order_id
    )
  end
end
