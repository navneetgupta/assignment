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
  alias SamMedia.Order.Queries.OrderQuery
  alias Ecto.Multi
  alias SamMedia.Repo

  project(%OrderCreated{} = created, %{stream_version: version}, fn multi ->
    IO.puts("Projectors OrderCreated  #{version}=====================")
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

  project(%OrderCompleted{} = completed, %{stream_version: version}, fn multi ->
    IO.puts("Projectors OrderCompleted  #{version}=====================")
    IO.inspect(completed)

    multi
    |> Multi.update_all(
      :order,
      OrderQuery.get_order(completed.order_uuid),
      [
        set: [
          payment_uuid: completed.payment_uuid,
          status: completed.order_status,
          payment_status: completed.payment_status,
          version: version
        ]
      ],
      returning: true
    )
  end)

  project(%OrderDelivered{} = delivered, %{stream_version: version}, fn multi ->
    IO.puts("Projectors OrderDelivered  #{version}=====================")
    IO.inspect(delivered)

    multi
    |> Multi.update_all(
      :order,
      OrderQuery.get_order(delivered.order_uuid),
      [
        set: [
          status: EnumsOrder.order_status()[:DELIVERED],
          version: version
        ]
      ],
      returning: true
    )
  end)

  project(%OrderCancelled{} = cancelled, %{stream_version: version}, fn multi ->
    IO.puts("Projectors OrderCancelled  #{version}=====================")
    IO.inspect(cancelled)

    multi
    |> Multi.update_all(
      :order,
      OrderQuery.get_order(cancelled.order_uuid),
      [
        set: [
          status: EnumsOrder.order_status()[:CANCELLED],
          payment_status: EnumsOrder.payment_status()[:refunded],
          refund_txn_uuid: cancelled.refund_txn_id,
          version: version
        ]
      ],
      returning: true
    )
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
