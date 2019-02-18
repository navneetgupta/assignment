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

  alias SamMedia.Payment.Commands.{
    InitiatePayment,
    CompletePayment,
    InitiateRefund,
    ProcessRefund
  }

  alias SamMedia.Payment.Events.{
    PaymentIntitated,
    PaymentCompleted,
    RefundInitiated,
    RefundProcessed
  }

  alias SamMedia.Payment.Enums.EnumsPayment

  @successful_payment EnumsPayment.payment_status()[:SUCCESS]
  @processing_refund EnumsPayment.payment_status()[:REFUND_PROCESSING]

  def execute(%Payment{uuid: nil} = z, %InitiatePayment{} = payment) do
    IO.puts("============Execute Initiate Payment==============")
    IO.inspect(payment)
    IO.inspect(z)
    IO.puts("============Execute Initiate Payment Finish==============")

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
        %Payment{uuid: uuid, amount: amount, order_uuid: order_uuid} = z,
        %CompletePayment{} = complete
      ) do
    IO.puts("============Execute CompletePayment Payment==============")
    IO.inspect(complete)
    IO.inspect(z)
    IO.puts("============Execute CompletePayment Payment Finish==============")

    %PaymentCompleted{
      payment_uuid: uuid,
      txn_uuid: complete.txn_uuid,
      status: complete.status,
      order_amount: amount,
      order_uuid: order_uuid
    }
  end

  def execute(%Payment{uuid: nil}, %InitiateRefund{}), do: {:error, :payment_dtls_not_found}

  def execute(%Payment{status: status}, %InitiateRefund{}) when status == @processing_refund,
    do: {:error, :refund_already_in_process}

  def execute(%Payment{status: status} = payment, %InitiateRefund{} = initiate)
      when status != @successful_payment do
    IO.puts("============Execute 2 InitiateRefund Payment #{@successful_payment}==============")
    IO.inspect(initiate)
    IO.inspect(payment)
    IO.puts("============Execute 2 InitiateRefund Payment Finish==============")

    {:error, :payment_dtls_not_found}
  end

  def execute(%Payment{order_uuid: order_uuid}, %InitiateRefund{order_uuid: refund_order_uuid})
      when order_uuid !== refund_order_uuid,
      do: {:error, :invalid_order_for_refund}

  def execute(
        %Payment{uuid: uuid} = z,
        %InitiateRefund{payment_uuid: payment_uuid, order_uuid: order_uuid} = initiate
      ) do
    IO.puts("============Execute InitiateRefund Payment==============")
    IO.inspect(initiate)
    IO.inspect(z)
    IO.puts("============Execute InitiateRefund Payment Finish==============")

    %RefundInitiated{
      payment_uuid: uuid,
      order_uuid: order_uuid
    }
  end

  def execute(%Payment{uuid: nil}, %ProcessRefund{}), do: {:error, :invalid_payment}

  def execute(%Payment{status: status}, %ProcessRefund{} = refund) do
    %RefundProcessed{
      order_uuid: refund.order_uuid,
      payment_uuid: refund.payment_uuid,
      txn_uuid: refund.txn_uuid
    }
  end

  def apply(%Payment{} = payment, %PaymentIntitated{} = payment_initiated) do
    IO.puts("============Apply PaymentIntitated Payment==============")
    IO.inspect(payment_initiated)
    IO.inspect(payment)
    IO.puts("============Apply PaymentIntitated Payment Finish==============")

    %Payment{
      payment
      | uuid: payment_initiated.payment_uuid,
        order_uuid: payment_initiated.order_uuid,
        amount: payment_initiated.amount,
        status: EnumsPayment.payment_status()[:PROCESSING]
    }
  end

  def apply(%Payment{} = payment, %PaymentCompleted{} = payment_completed) do
    IO.puts("============Apply PaymentCompleted Payment==============")
    IO.inspect(payment_completed)
    IO.inspect(payment)
    IO.puts("============Apply PaymentCompleted Payment Finish==============")

    %Payment{
      payment
      | transaction_uuid: payment_completed.txn_uuid,
        status: payment_completed.status
    }
  end

  def apply(%Payment{} = payment, %RefundInitiated{} = initiated) do
    IO.puts("============Apply RefundInitiated Payment==============")
    IO.inspect(initiated)
    IO.inspect(payment)
    IO.puts("============Apply RefundInitiated Payment Finish==============")

    %Payment{
      payment
      | status: EnumsPayment.payment_status()[:REFUND_PROCESSING]
    }
  end

  def apply(%Payment{} = payment, %RefundProcessed{} = refund_processed) do
    IO.puts("============Apply RefundProcessed Payment==============")
    IO.inspect(refund_processed)
    IO.inspect(payment)
    IO.puts("============Apply RefundProcessed Payment Finish==============")

    %Payment{
      payment
      | refund_txn_uuid: refund_processed.txn_uuid,
        status: EnumsPayment.payment_status()[:REFUNDED]
    }
  end
end
