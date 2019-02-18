defmodule SamMedia.Order.Aggregates.Order do
  alias __MODULE__

  defstruct uuid: nil,
            user_name: "",
            user_mobile: "",
            amount: 0,
            payment_uuid: "",
            refund_txn_id: "",
            status: "",
            payment_status: ""

  alias SamMedia.Order.Commands.{
    CreateOrder,
    InitiateOrderCancellation,
    CompleteOrder,
    DeliverOrder,
    CancelOrder
  }

  alias SamMedia.Order.Events.{
    OrderCreated,
    OrderCancellationInitiated,
    OrderCancelled,
    OrderCompleted,
    OrderDelivered
  }

  alias SamMedia.Order.Enums.EnumsOrder

  @status_confirmed EnumsOrder.order_status()[:CONFIRMED]
  @status_created EnumsOrder.order_status()[:CREATED]
  @status_cancelled EnumsOrder.order_status()[:CANCELLED]

  @payment_processing EnumsOrder.payment_status()[:processing]
  @payemnt_refunding EnumsOrder.payment_status()[:refunding]
  @payemnt_refunded EnumsOrder.payment_status()[:refunded]
  @payemnt_declined EnumsOrder.payment_status()[:declined]
  @payment_success EnumsOrder.payment_status()[:success]

  def execute(%Order{}, %CreateOrder{amount: amount}) when amount == 0 do
    {:error, :invalid_order_amount}
  end

  def execute(%Order{} = order, %CreateOrder{} = create) do
    IO.puts("Aggregate------------------------------")
    IO.inspect(order)
    IO.inspect(create)

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

  def execute(%Order{} = order, %CompleteOrder{order_status: status} = complete) do
    IO.puts("Aggregate---------CompleteOrder---------------------")
    IO.inspect(order)
    IO.inspect(complete)
    IO.puts("Aggregate---------CompleteOrder Finish---------------------")

    %OrderCompleted{
      order_uuid: complete.order_uuid,
      payment_uuid: complete.payment_uuid,
      order_status: status,
      payment_status: complete.payment_status
    }
  end

  def execute(%Order{uuid: nil}, %DeliverOrder{}), do: {:error, :invalid_order}

  def execute(%Order{uuid: _uuid, status: status}, %DeliverOrder{})
      when status !== @status_confirmed do
    {:error, :order_not_confirmed}
  end

  def execute(%Order{uuid: uuid}, %DeliverOrder{}) do
    %OrderDelivered{
      order_uuid: uuid
    }
  end

  def execute(%Order{uuid: nil}, %InitiateOrderCancellation{}), do: {:error, :invalid_order}

  def execute(
        %Order{status: status, payment_status: payment_status},
        %InitiateOrderCancellation{}
      )
      when status === @status_created and payment_status === @payment_processing,
      do: {:error, :txn_in_process_retry_after_some_time}

  def execute(
        %Order{status: status, payment_status: payment_status},
        %InitiateOrderCancellation{}
      )
      when status === @status_cancelled and payment_status === @payemnt_refunding,
      do: {:error, :cancellation_already_requested}

  def execute(
        %Order{status: status, payment_status: payment_status},
        %InitiateOrderCancellation{}
      )
      when status === @status_cancelled and payment_status === @payemnt_refunded,
      do: {:error, :cancellation_already_processed}

  def execute(
        %Order{status: status, payment_status: payment_status},
        %InitiateOrderCancellation{}
      )
      when status === @status_cancelled and payment_status === @payemnt_declined,
      do: {:error, :order_cancelled_due_to_payment_failure}

  def execute(
        %Order{status: status, payment_status: payment_status},
        %InitiateOrderCancellation{}
      )
      when status === @status_confirmed and payment_status === @payment_success,
      do: {:error, :shippment_out_for_delivery_try_after_some_time}

  def execute(
        %Order{
          uuid: uuid,
          payment_uuid: payment_uuid
        } = order,
        %InitiateOrderCancellation{} = cancellation
      ) do
    IO.puts(" AGGREGATE =============InitiateOrderCancellation")
    IO.inspect(cancellation)
    IO.inspect(order)
    IO.puts(" AGGREGATE =============InitiateOrderCancellation")

    %OrderCancellationInitiated{
      order_uuid: uuid,
      payment_uuid: payment_uuid
    }
  end

  def execute(%Order{} = order, %CancelOrder{} = cancel) do
    IO.puts(" AGGREGATE =============CancelOrder")
    IO.inspect(cancel)
    IO.inspect(order)
    IO.puts(" AGGREGATE =============CancelOrder")

    %OrderCancelled{
      order_uuid: cancel.order_uuid,
      refund_txn_id: cancel.txn_uuid
    }
  end

  def apply(%Order{} = order, %OrderCreated{} = created) do
    %Order{
      order
      | uuid: created.order_uuid,
        amount: created.order_amount,
        status: EnumsOrder.order_status()[:CREATED],
        user_name: created.user_name,
        user_mobile: created.user_mobile,
        payment_status: EnumsOrder.payment_status()[:processing]
    }
  end

  def apply(%Order{} = order, %OrderCompleted{order_status: status} = completed) do
    %Order{
      order
      | status: status,
        payment_status: completed.payment_status,
        payment_uuid: completed.payment_uuid
    }
  end

  def apply(%Order{} = order, %OrderDelivered{}) do
    %Order{order | status: EnumsOrder.order_status()[:DELIVERED]}
  end

  def apply(%Order{} = order, %OrderCancellationInitiated{}) do
    %Order{
      order
      | status: EnumsOrder.order_status()[:CANCELLED],
        payment_status: EnumsOrder.payment_status()[:refunding]
    }
  end

  def apply(%Order{} = order, %OrderCancelled{} = cancelled) do
    IO.puts(" AGGREGATE =============OrderCancelled ")
    IO.inspect(cancelled)
    IO.inspect(order)
    IO.puts(" AGGREGATE =============OrderCancelled")

    %Order{
      order
      | status: EnumsOrder.order_status()[:CANCELLED],
        payment_status: EnumsOrder.payment_status()[:refunded],
        refund_txn_id: cancelled.refund_txn_id
    }
  end
end
