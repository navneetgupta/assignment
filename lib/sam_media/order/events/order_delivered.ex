defmodule SamMedia.Order.Events.OrderDelivered do
  @derive Jason.Encoder

  defstruct [:order_uuid]
end
