defmodule SamMedia.Payment.Events.RefundInitiated do
  @derive Jason.Encoder

  defstruct [:payment_uuid, :order_uuid]
end
