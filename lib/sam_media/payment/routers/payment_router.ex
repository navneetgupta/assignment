defmodule SamMedia.Payment.Routers.PaymentRouter do
  use Commanded.Commands.Router

  alias SamMedia.Payment.Aggregates.Payment

  alias SamMedia.Payment.Commands.{
    InitiatePayment,
    CompletePayment,
    ProcessRefund,
    InitiateRefund
  }

  alias SamMedia.Support.Validators.Validate

  middleware(Commanded.Middleware.Logger)
  middleware(Validate)

  dispatch(InitiatePayment, to: Payment, identity: :uuid)
  dispatch(CompletePayment, to: Payment, identity: :payment_uuid)
  dispatch(InitiateRefund, to: Payment, identity: :payment_uuid)
  dispatch(ProcessRefund, to: Payment, identity: :payment_uuid)
end
