defmodule SamMedia.Payment.Aggregates.Payment do
  alias __MODULE__
  import Integer

  @moduledoc """

  """

  defstruct [
    :uuid,
    :order_uuid,
    :amount,
    :transaction_uuid,
    :refund_txn_uuid,
    :status
  ]

  alias SamMedia.Payment.Commands.{InitiatePayment, CompletePayment, ProcessRefund}
  alias SamMedia.Payment.Events.{PaymentIntitated, PaymentCompleted, RefundProcessed}
  alias SamMedia.Payment.Enums.EnumsPayment

  @successful_payment EnumsPayment.payment_status()[:SUCCESS]

  def execute(%Payment{uuid: nil} = _z, %InitiatePayment{card_number: card_number} = payment) do
    IO.puts("============Execute Initiate Payment==============")

    %PaymentIntitated{
      payment_uuid: payment.uuid,
      amount: payment.order_amount,
      card_number: payment.card_number,
      card_security_code: payment.card_security_code,
      card_holder_name: payment.card_holder_name,
      card_expiry: payment.card_expiry,
      order_uuid: payment.order_uuid
    }
  end

  def execute(
        %Payment{uuid: uuid, amount: amount, order_uuid: order_uuid} = payment,
        %CompletePayment{} = complete
      ) do
    %PaymentCompleted{
      payment_uuid: uuid,
      txn_uuid: complete.txn_uuid,
      status: complete.status,
      order_amount: amount,
      order_uuid: order_uuid
    }
  end

  def execute(%Payment{uuid: nil}, %ProcessRefund{}), do: {:error, :payment_dtls_not_found}

  def execute(%Payment{status: status}, %ProcessRefund{}) when status !== @successful_payment,
    do: {:error, :payment_dtls_not_found}

  def execute(%Payment{order_uuid: order_uuid}, %ProcessRefund{order_uuid: refund_order_uuid})
      when order_uuid !== refund_order_uuid,
      do: {:error, :invalid_order_for_refund}

  def execute(
        %Payment{uuid: uuid} = _z,
        %ProcessRefund{payment_uuid: payment_uuid, order_uuid: order_uuid}
      ) do
    %RefundProcessed{
      payment_uuid: uuid,
      order_uuid: order_uuid,
      txn_uuid: UUID.uuid4()
    }
  end

  def apply(%Payment{} = payment, %PaymentIntitated{} = payment_initiated) do
    %Payment{
      payment
      | uuid: payment_initiated.payment_uuid,
        order_uuid: payment_initiated.order_uuid,
        amount: payment_initiated.amount,
        status: EnumsPayment.payment_status()[:PROCESSING]
    }
  end

  def apply(%Payment{} = payment, %PaymentCompleted{} = payment_completed) do
    %Payment{
      payment
      | transaction_uuid: payment_completed.txn_uuid,
        status: payment_completed.status
    }
  end

  def apply(%Payment{} = payment, %RefundProcessed{} = refund_processed) do
    %Payment{
      payment
      | refund_txn_uuid: refund_processed.txn_uuid,
        status: EnumsPayment.payment_status()[:REFUNDED]
    }
  end
end
