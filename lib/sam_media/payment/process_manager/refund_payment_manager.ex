defmodule SamMedia.Payment.ProcessManager.RefundPaymentManager do
  use Commanded.ProcessManagers.ProcessManager,
    name: "RefundPaymentManager",
    router: SamMedia.Router

  alias __MODULE__

  @derive [Jason.Encoder]
  defstruct payment_uuid: nil,
            order_uuid: nil,
            status: nil,
            txn_uuid: nil

  alias SamMedia.Payment.Events.{RefundInitiated, RefundProcessed}
  alias SamMedia.Payment.Commands.ProcessRefund
  alias SamMedia.Payment.Enums.EnumsPayment
  def interested?(%RefundInitiated{payment_uuid: payment_uuid}), do: {:start, payment_uuid}
  def interested?(%RefundProcessed{payment_uuid: payment_uuid}), do: {:stop, payment_uuid}

  def handle(%RefundPaymentManager{}, %RefundInitiated{} = initiated) do
    %ProcessRefund{
      payment_uuid: initiated.payment_uuid,
      order_uuid: initiated.order_uuid,
      txn_uuid: UUID.uuid4()
    }
  end

  def apply(%RefundPaymentManager{} = refund_manager, %RefundInitiated{} = initiated) do
    %RefundPaymentManager{
      refund_manager
      | payment_uuid: initiated.payment_uuid,
        order_uuid: initiated.order_uuid,
        status: :refunding
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
