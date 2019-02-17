defmodule SamMedia.Order.Projectors.Order do
  use Commanded.Projections.Ecto,
    name: "Order.Projectors.Order"

  alias SamMedia.Order.Events.OrderCreated
  alias SamMedia.Order.Events.OrderCompleted
  alias SamMedia.Order.Events.OrderCancelled
  alias SamMedia.Order.Events.OrderDelivered
  alias SamMedia.Order.Projections.Order
  alias SamMedia.Order.Pubsub, as: OrderPubSub
  alias SamMedia.Order.Enums.EnumsOrder

  project %OrderCreated{} = created, %{stream_version: version} do
    Ecto.Multi.insert(multi, :order, %Order{
      uuid: created.order_uuid,
      user_name: created.user_name,
      user_mobile: created.user_mobile,
      amount: created.order_amount,
      status: EnumsOrder.order_status()[:CREATED]
    })
  end

  def after_update(_event, _metadata, changes) do
    spawn(fn ->
      schedule(changes)
    end)

    :ok
  end

  defp schedule(changes) do
    :timer.sleep(500)
    OrderPubSub.publish_changes(changes)
  end
end
