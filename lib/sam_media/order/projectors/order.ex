defmodule SamMedia.Order.Projectors.Order do
  use Commanded.Projections.Ecto,
    name: "Order.Projectors.Order"

  alias SamMedia.Order.Events.OrderCreated
  alias SamMedia.Order.Events.OrderCompleted
  alias SamMedia.Order.Events.OrderCancelled
  alias SamMedia.Order.Events.OrderDelivered
  alias SamMedia.Order.Projections.Order, as: OrderPro
  alias SamMedia.Order.Pubsub, as: OrderPubSub
  alias SamMedia.Order.Enums.EnumsOrder
  alias Ecto.Multi
  alias SamMedia.Repo

  project(%OrderCreated{} = created, %{stream_version: version}, fn multi ->
    IO.puts("Projectors OrderCreated=====================")
    IO.inspect(created)

    Ecto.Multi.insert(multi, :order, %OrderPro{
      uuid: created.order_uuid,
      user_name: created.user_name,
      user_mobile: created.user_mobile,
      amount: created.order_amount,
      status: EnumsOrder.order_status()[:CREATED],
      version: version
    })
  end)

  def after_update(_event, _metadata, changes) do
    IO.puts("after_update------------------------------")
    IO.inspect(changes)

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
