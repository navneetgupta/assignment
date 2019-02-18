defmodule SamMedia.Order.Events.OrderCompleted do
  @derive Jason.Encoder

  defstruct [:order_uuid, :payment_uuid, :order_status, :payment_status]
end
