defmodule SamMedia.Order.ProcessManager.OrderManager do
  use Commanded.ProcessManagers.ProcessManager,
    name: "OrderManager",
    router: SamMedia.Router

  alias __MODULE__

  @derive [Jason.Encoder]
  defstruct order_uuid: nil,
            order_amount: 0,
            payment_status: nil,
            order_status: nil

  alias SamMedia.Payment.Events.PaymentCompleted

  alias SamMedia.Order.Events.{
    OrderCreated,
    OrderCompleted,
    OrderDelivered
  }

  alias SamMedia.Order.Commands.{CompleteOrder, DeliverOrder}
  alias SamMedia.Payment.Commands.{InitiatePayment}
  alias SamMedia.Order.Enums.EnumsOrder
  alias SamMedia.Payment.Enums.EnumsPayment

  @payment_success EnumsPayment.payment_status()[:SUCCESS]

  @order_success EnumsOrder.order_status()[:CONFIRMED]

  def interested?(%OrderCreated{order_uuid: order_uuid}), do: {:start, order_uuid}
  def interested?(%PaymentCompleted{order_uuid: order_uuid}), do: {:continue, order_uuid}
  def interested?(%OrderCompleted{order_uuid: order_uuid}), do: {:continue, order_uuid}
  def interested?(%OrderDelivered{order_uuid: order_uuid}), do: {:stop, order_uuid}

  def handle(%OrderManager{}, %OrderCreated{} = created) do
    IO.puts("================Order Manager OrderCreated==========")
    IO.inspect(created)
    IO.puts("================Order Manager OrderCreated Finished==========")

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

  def handle(
        %OrderManager{} = z,
        %PaymentCompleted{status: status} = completed
      ) do
    IO.puts("================Order Manager PaymentCompleted==========")
    IO.inspect(completed)
    IO.inspect(z)
    IO.puts("================Order Manager PaymentCompleted Finished==========")

    cond do
      status === @payment_success ->
        %CompleteOrder{
          order_uuid: completed.order_uuid,
          payment_uuid: completed.payment_uuid,
          order_status: EnumsOrder.order_status()[:CONFIRMED],
          payment_status: EnumsOrder.payment_status()[:success]
        }

      true ->
        %CompleteOrder{
          order_uuid: completed.order_uuid,
          payment_uuid: completed.payment_uuid,
          order_status: EnumsOrder.order_status()[:CANCELLED],
          payment_status: EnumsOrder.payment_status()[:declined]
        }
    end
  end

  def handle(
        %OrderManager{order_uuid: order_uuid} = z,
        %OrderCompleted{order_status: status} = completed
      ) do
    IO.puts("================Order Manager OrderCompleted==========")
    IO.inspect(completed)
    IO.inspect(z)
    IO.puts("order status #{@order_success}")
    IO.puts("================Order Manager OrderCompleted Finished==========")

    cond do
      status === @order_success ->
        %DeliverOrder{
          order_uuid: order_uuid
        }

      true ->
        []
    end
  end

  def apply(%OrderManager{} = order_manager, %OrderCreated{} = created) do
    %OrderManager{
      order_manager
      | order_uuid: created.order_uuid,
        order_amount: created.order_amount,
        payment_status: EnumsOrder.payment_status()[:processing],
        order_status: EnumsOrder.order_status()[:CREATED]
    }
  end

  def apply(%OrderManager{} = order_manager, %PaymentCompleted{status: status}) do
    cond do
      status === @payment_success ->
        %OrderManager{
          order_manager
          | order_status: EnumsOrder.order_status()[:CONFIRMED],
            payment_status: EnumsOrder.payment_status()[:success]
        }

      true ->
        %OrderManager{
          order_manager
          | order_status: EnumsOrder.order_status()[:CANCELLED],
            payment_status: EnumsOrder.payment_status()[:declined]
        }
    end
  end

  def apply(%OrderManager{} = order_manager, %OrderCompleted{order_status: status})
      when status === @order_success do
    %OrderManager{
      order_manager
      | order_status: :delivering
    }
  end

  # Stop process manager after three failures
  def error({:error, _failure}, _failed_command, %{context: %{failures: failures}})
      when failures >= 2 do
    # take Corrective Measures
    {:stop, :too_many_failures}
  end

  # Retry command, record failure count in context map
  def error({:error, _failure}, _failed_command, %{context: context}) do
    context = Map.update(context, :failures, 1, fn failures -> failures + 1 end)
    {:retry, context}
  end
end
