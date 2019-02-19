defmodule SamMedia.Order.ProcessManager.RefundManager do
  use Commanded.ProcessManagers.ProcessManager,
    name: "RefundManager",
    router: SamMedia.Router

  alias __MODULE__

  @derive [Jason.Encoder]
  defstruct order_uuid: nil,
            payment_uuid: nil,
            refund_txn_id: nil

  alias SamMedia.Order.Events.{OrderCancellationInitiated, OrderCancelled}
  alias SamMedia.Order.Commands.CancelOrder
  alias SamMedia.Payment.Commands.InitiateRefund
  alias SamMedia.Payment.Events.RefundProcessed

  def interested?(%OrderCancellationInitiated{order_uuid: order_uuid}), do: {:start, order_uuid}
  def interested?(%RefundProcessed{order_uuid: order_uuid}), do: {:continue, order_uuid}
  def interested?(%OrderCancelled{order_uuid: order_uuid}), do: {:stop, order_uuid}

  def handle(%RefundManager{}, %OrderCancellationInitiated{} = initiated) do
    %InitiateRefund{
      payment_uuid: initiated.payment_uuid,
      order_uuid: initiated.order_uuid
    }
  end

  def handle(%RefundManager{}, %RefundProcessed{} = refund_processed) do
    %CancelOrder{
      order_uuid: refund_processed.order_uuid,
      payment_uuid: refund_processed.payment_uuid,
      txn_uuid: refund_processed.txn_uuid
    }
  end

  def apply(%RefundManager{} = refund_manager, %OrderCancellationInitiated{} = initiated) do
    %RefundManager{
      refund_manager
      | order_uuid: initiated.order_uuid,
        payment_uuid: initiated.payment_uuid
    }
  end

  def apply(%RefundManager{} = refund_manager, %RefundProcessed{} = refund_processed) do
    %RefundManager{
      refund_manager
      | refund_txn_id: refund_processed.txn_uuid
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
