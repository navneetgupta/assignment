defmodule SamMedia.Payment.Events.PaymentIntitated do
  @derive Jason.Encoder

  defstruct [
    :payment_uuid,
    :amount,
    :card_number,
    :card_security_code,
    :card_holder_name,
    :card_expiry,
    :order_uuid
  ]
end
