defmodule SamMedia.Order.Aggregates.Order do
  alias __MODULE__

  defstruct uuid: "",
            user_name: "",
            user_mobile: "",
            amount: 0,
            payment_uuid: "",
            refund_txn_id: "",
            status: ""

  alias SamMedia.Order.Commands.{CreateOrder, CancelOrder, CompleteOrder, DeliverOrder}
  alias SamMedia.Order.Events.{OrderCreated, OrderCancelled, OrderCompleted, OrderDelivered}
  alias SamMedia.Order.Enums.EnumsOrder

  @status_success EnumsOrder.order_status()[:SUCCESS]
  @status_confirmed EnumsOrder.order_status()[:CONFIRMED]

  def execute(%Order{} = order, %CreateOrder{amount: amount} = create) when amount == 0 do
    {:error, :invalid_order_amount}
  end

  def execute(%Order{} = order, %CreateOrder{} = create) do
    %OrderCreated{
      order_uuid: create.uuid,
      card_number: create.card_number,
      card_holder_name: create.card_holder_name,
      card_expiry: create.card_expiry,
      card_security_code: create.card_security_code,
      order_amount: create.amount,
      user_name: create.user_name,
      user_mobile: create.user_mobile
    }
  end

  def execute(%Order{uuid: nil}, %CompleteOrder{}), do: {:error, :invalid_order}

  def execute(%Order{} = order, %CompleteOrder{status: status} = complete) do
    %OrderCompleted{
      order_uuid: complete.order_uuid,
      payment_uuid: complete.payment_uuid,
      status: complete.status
    }
  end

  def execute(%Order{uuid: nil}, %DeliverOrder{} = complete), do: {:error, :invalid_order}

  def execute(%Order{uuid: _uuid, status: status}, %DeliverOrder{})
      when status !== @status_confirmed do
    {:error, :order_not_confirmed}
  end

  def execute(%Order{uuid: uuid} = order, %DeliverOrder{} = deliver) do
    %OrderDelivered{
      order_uuid: uuid
    }
  end

  def apply(%Order{} = order, %OrderCreated{} = created) do
    %Order{
      order
      | uuid: created.order_uuid,
        amount: created.order_amount,
        status: EnumsOrder.order_status()[:CREATED],
        user_name: created.user_name,
        user_mobile: created.user_mobile
    }
  end

  def apply(%Order{} = order, %OrderCompleted{status: status} = completed) do
    %Order{order | status: status}
  end

  def apply(%Order{} = order, %OrderDelivered{}) do
    %Order{order | status: EnumsOrder.order_status()[:DELIVERED]}
  end
end
