defmodule SamMedia.Payment.Events.RefundProcessed do
  @derive Jason.Encoder

  defstruct [:payment_uuid, :order_uuid, :txn_uuid]
end
