defmodule SamMedia.Payment.Events.PaymentCompleted do
  @derive Jason.Encoder

  defstruct [:payment_uuid, :txn_uuid, :status, :order_amount]
end
