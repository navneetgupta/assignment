defmodule SamMedia.Order.Events.OrderCreated do
  @derive Jason.Encoder

  defstruct [
    :order_uuid,
    :card_number,
    :card_holder_name,
    :card_expiry,
    :card_security_code,
    :order_amount,
    :user_name,
    :user_mobile
  ]
end
