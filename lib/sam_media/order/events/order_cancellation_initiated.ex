defmodule SamMedia.Order.Events.OrderCancellationInitiated do
  @derive Jason.Encoder

  defstruct [:order_uuid, :payment_uuid]
end
