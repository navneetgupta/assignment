defmodule SamMedia.Order.ProcessManager.OrderManager do
  use Commanded.ProcessManagers.ProcessManager,
    name: "OrderManager",
    router: SamMedia.Router

  alias __MODULE__

  @derive [Jason.Encoder]
  defstruct order_uuid: nil,
            order_amount: 0,
            status: nil

  alias SamMedia.Payment.Events.PaymentCompleted
  alias SamMedia.Order.Events.{OrderCreated, OrderCancelled, OrderCompleted, OrderDelivered}
  alias SamMedia.Order.Commands.{CompleteOrder, DeliverOrder}
  alias SamMedia.Payment.Commands.{InitiatePayment}
  alias SamMedia.Order.Enums.EnumsOrder
  alias SamMedia.Payment.Enums.EnumsPayment

  @payment_success EnumsPayment.payment_status()[:SUCCESS]
  @payment_declined EnumsPayment.payment_status()[:DECLINED]

  @order_success EnumsOrder.order_status()[:SUCCESS]
  @order_cancelled EnumsOrder.order_status()[:CANCELLED]

  def interested?(%OrderCreated{order_uuid: order_uuid}), do: {:start, order_uuid}
  def interested?(%PaymentCompleted{order_uuid: order_uuid}), do: {:continue, order_uuid}
  def interested?(%OrderCompleted{order_uuid: order_uuid}), do: {:continue, order_uuid}
  def interested?(%OrderDelivered{order_uuid: order_uuid}), do: {:stop, order_uuid}

  def handle(%OrderManager{}, %OrderCreated{} = created) do
    %InitiatePayment{
      uuid: UUID.uuid4(),
      order_uuid: created.order_uuid,
      card_number: created.card_number,
      card_holder_name: created.card_holder_name,
      card_expiry: created.card_expiry,
      card_security_code: created.card_security_code,
      order_amount: created.order_amount
    }
  end

  def handle(%OrderManager{}, %PaymentCompleted{status: status} = completed) do
    cond do
      status === @payment_success ->
        %CompleteOrder{
          order_uuid: completed.order_uuid,
          payment_uuid: completed.payment_uuid,
          status: EnumsOrder.order_status()[:CONFIRMED]
        }

      true ->
        %CompleteOrder{
          order_uuid: completed.order_uuid,
          payment_uuid: completed.payment_uuid,
          status: EnumsOrder.order_status()[:CANCELLED]
        }
    end
  end

  def handle(%OrderManager{order_uuid: order_uuid}, %OrderCompleted{status: status})
      when status === @order_success do
    %DeliverOrder{
      order_uuid: order_uuid
    }
  end

  def apply(%OrderManager{} = order_manager, %OrderCreated{} = created) do
    %OrderManager{
      order_manager
      | order_uuid: created.order_uuid,
        order_amount: created.order_amount,
        status: EnumsOrder.payment_status()[:processing]
    }
  end

  def apply(%OrderManager{} = order_manager, %PaymentCompleted{status: status} = completed) do
    cond do
      status === @payment_success ->
        %OrderManager{
          order_manager
          | status: EnumsOrder.payment_status()[:success]
        }

      true ->
        %OrderManager{
          order_manager
          | status: EnumsOrder.payment_status()[:declined]
        }
    end
  end
end
