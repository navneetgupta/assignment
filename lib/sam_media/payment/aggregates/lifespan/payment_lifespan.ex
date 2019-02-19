defmodule SamMedia.Payment.Aggregates.Lifespan.PaymentLifespan do
  @behaviour Commanded.Aggregates.AggregateLifespan

  alias SamMedia.Payment.Commands.{
    InitiatePayment,
    CompletePayment,
    ProcessRefund
  }

  alias SamMedia.Payment.Events.{
    PaymentIntitated,
    PaymentCompleted,
    RefundProcessed
  }

  def after_event(%PaymentIntitated{}), do: :infinity
  def after_event(%PaymentCompleted{}), do: :stop
  def after_event(%RefundProcessed{}), do: :stop
  def after_event(_event), do: 100_000

  def after_command(%InitiatePayment{}), do: :infinity
  def after_command(%CompletePayment{}), do: :stop
  def after_command(%ProcessRefund{}), do: :stop
  def after_command(_command), do: 100_000

  def after_error(:payment_dtls_not_found), do: :stop
  def after_error(_error), do: :infinity
end
