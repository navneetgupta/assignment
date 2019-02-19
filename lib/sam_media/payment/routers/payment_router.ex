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
  alias SamMedia.Payment.Aggregates.Lifespan.PaymentLifespan

  middleware(Commanded.Middleware.Logger)
  middleware(Validate)

  dispatch(InitiatePayment, lifespan: PaymentLifespan, to: Payment, identity: :uuid)
  dispatch(CompletePayment, lifespan: PaymentLifespan, to: Payment, identity: :payment_uuid)
  dispatch(InitiateRefund, lifespan: PaymentLifespan, to: Payment, identity: :payment_uuid)
  dispatch(ProcessRefund, lifespan: PaymentLifespan, to: Payment, identity: :payment_uuid)
end
