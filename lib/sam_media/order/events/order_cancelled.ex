defmodule SamMedia.Order.Events.OrderCancelled do
  @derive Jason.Encoder

  defstruct [:order_uuid, :refund_txn_id]
end
